#!/bin/bash

GRUB_VERSION="2.12"
KBD_VERSION="2.10.0"

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
ISO_PATH="$(readlink -f "$SCRIPT_PATH/../iso")"
SYSLINUX_PATH="$ISO_PATH/boot/syslinux"
BUILD_PATH="$(mktemp -d)"
trap 'rm -rf "$BUILD_PATH"' EXIT
NUMBER_THREADS=$(nproc)

for tool in gcc make bison flex python3 patch mformat mmd mcopy wget; do
	command -v $tool > /dev/null 2>&1 || { echo "Required tool not found: $tool"; exit 1; }
done

cd "$BUILD_PATH" || exit 1

wget -q "https://ftp.gnu.org/gnu/grub/grub-${GRUB_VERSION}.tar.xz" || { echo "Failed to download grub."; exit 1; }
wget -q "https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-${KBD_VERSION}.tar.xz" || { echo "Failed to download kbd."; exit 1; }
tar xf grub-${GRUB_VERSION}.tar.xz || exit 1
tar xf kbd-${KBD_VERSION}.tar.xz kbd-${KBD_VERSION}/data/consolefonts/cp865-8x16.psfu || exit 1

patch -d grub-${GRUB_VERSION} -p1 < "$SCRIPT_PATH/grub-hidden-menuentry.patch" > /dev/null || { echo "Failed to patch grub."; exit 1; }
echo "depends bli part_gpt" > grub-${GRUB_VERSION}/grub-core/extra_deps.lst

for platform in i386-efi x86_64-efi i386-pc; do
	echo "Building grub for $platform..."
	mkdir -p build-$platform
	cd build-$platform || exit 1
	../grub-${GRUB_VERSION}/configure --prefix="$BUILD_PATH/$platform" --target=${platform%%-*} --with-platform=${platform#*-} --disable-werror > /dev/null 2>&1 || { echo "Failed to configure grub for $platform."; exit 1; }
	make -j$NUMBER_THREADS > /dev/null 2>&1 || { echo "Failed to build grub for $platform."; exit 1; }
	make install > /dev/null 2>&1 || { echo "Failed to install grub for $platform."; exit 1; }
	cd .. || exit 1
done

[ -x "$BUILD_PATH/i386-efi/bin/grub-mkfont" ] || { echo "grub-mkfont was not built. Install freetype development files."; exit 1; }

mkdir -p theme

python3 -I - kbd-${KBD_VERSION}/data/consolefonts/cp865-8x16.psfu vga.bdf <<'EOF'
import struct, sys
data = open(sys.argv[1], 'rb').read()
magic, version, header_size, flags, count, char_size, height, width = struct.unpack('<8I', data[:32])
glyphs = [data[header_size + i * char_size:header_size + (i + 1) * char_size] for i in range(count)]
codepoints = {}
position = header_size + count * char_size
for i in range(count):
	sequence = b''
	while data[position] != 0xFF:
		sequence += bytes([data[position]])
		position += 1
	position += 1
	for char in sequence.split(b'\xfe')[0].decode('utf-8', errors='ignore'):
		codepoints.setdefault(ord(char), i)
for heavy, light in ((0x2501, 0x2500), (0x2503, 0x2502), (0x250f, 0x250c), (0x2513, 0x2510), (0x2517, 0x2514), (0x251b, 0x2518)):
	if light in codepoints:
		codepoints[heavy] = codepoints[light]
keep = set(range(0x20, 0x7f)) | set(range(0x2190, 0x2196)) | set(range(0x2500, 0x251c)) | {0x25b2, 0x25ba, 0x25bc, 0x25c4}
codepoints = {key: value for key, value in codepoints.items() if key in keep}
lines = ['STARTFONT 2.1', 'FONT -misc-vga-medium-r-normal--16-160-72-72-c-80-iso10646-1', 'SIZE 16 72 72', 'FONTBOUNDINGBOX 8 16 0 -4',
	'STARTPROPERTIES 3', 'FAMILY_NAME "vga"', 'FONT_ASCENT 12', 'FONT_DESCENT 4', 'ENDPROPERTIES', 'CHARS %d' % len(codepoints)]
for codepoint in sorted(codepoints):
	lines += ['STARTCHAR u%04X' % codepoint, 'ENCODING %d' % codepoint, 'SWIDTH 500 0', 'DWIDTH 8 0', 'BBX 8 16 0 -4', 'BITMAP']
	lines += ['%02X' % byte for byte in glyphs[codepoints[codepoint]]]
	lines.append('ENDCHAR')
lines.append('ENDFONT')
open(sys.argv[2], 'w').write('\n'.join(lines) + '\n')
EOF
[ -f vga.bdf ] || { echo "Failed to convert font."; exit 1; }
"$BUILD_PATH/i386-efi/bin/grub-mkfont" -o theme/vga.pf2 vga.bdf > /dev/null 2>&1 || { echo "Failed to create grub font."; exit 1; }

python3 -I - theme <<'EOF'
import struct, sys, zlib
def chunk(kind, data):
	return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data) & 0xffffffff)
for name, color, width in (('sel_c.png', (0x00, 0x96, 0xff), 1), ('sel_w.png', (0x00, 0x96, 0xff), 8), ('cover.png', (0, 0, 0), 1)):
	raw = b'\0' + bytes(color) * width
	png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', width, 1, 8, 2, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b'')
	open(sys.argv[1] + '/' + name, 'wb').write(png)
EOF

cp "$SYSLINUX_PATH/bootlogo.png" theme/ || exit 1

cat > theme/menu.txt <<'EOF'
title-text: ""
desktop-image: "bootlogo.png"
desktop-color: "#000000"
+ label { id = "__timeout__" left = 312 top = 712 width = 328 height = 16 font = "vga Regular 16" color = "#bcbcbc" text = "Press Esc for options, automatic boot in " }
+ label { id = "__timeout__" left = 640 top = 712 width = 8 height = 16 font = "vga Regular 16" color = "#e1e1e1" text = "%d" }
+ label { id = "__timeout__" left = 648 top = 712 width = 120 height = 16 font = "vga Regular 16" color = "#bcbcbc" text = " second(s)..." }
+ progress_bar { id = "__timeout__" left = 216 top = 648 width = 616 height = 96 fg_color = "#000000" bg_color = "#000000" border_color = "#000000" show_text = false }
+ boot_menu {
  left = 416 top = 648 width = 216 height = 80
  item_font = "vga Regular 16" selected_item_font = "vga Regular 16"
  item_color = "#ffffff" selected_item_color = "#ffffff"
  item_height = 16 item_padding = 0 item_spacing = 0
  icon_width = 0 icon_height = 0 item_icon_space = 0
  selected_item_pixmap_style = "sel_*.png"
  scrollbar = false scrollbar_left_pad = 0
}
+ label { left = 216 top = 728 width = 200 height = 16 font = "vga Regular 16" color = "#0096ff" text = "[F1] help" }
+ label { left = 632 top = 728 width = 200 height = 16 align = "right" font = "vga Regular 16" color = "#0096ff" text = "[e] edit >" }
EOF

{
	echo 'title-text: ""'
	echo 'desktop-image: "cover.png"'
	echo 'desktop-color: "#000000"'
	line_number=0
	tr -d '\r' < "$SYSLINUX_PATH/help.txt" | while IFS= read -r line; do
		line=${line//\\/\\\\}
		line=${line//\"/\\\"}
		echo "+ label { left = 8 top = $((8 + 16 * line_number)) width = 1016 height = 16 font = \"vga Regular 16\" color = \"#c6c6c6\" text = \"$line\" }"
		line_number=$((line_number + 1))
	done
} > theme/help.txt

cat > early.cfg <<'EOF'
if [ ! -f /boot/syslinux/initrd.zst ]; then
	regexp --set=1:bootdisk '^\(([^,)]+)' "$cmdpath"
	search.file /boot/syslinux/initrd.zst root "$bootdisk,"
fi
set prefix=(memdisk)/boot/grub
EOF

cat > theme/grub.cfg <<'EOF'
loadfont $prefix/vga.pf2
set gfxmode=1024x768,auto
terminal_output gfxterm
set theme=$prefix/menu.txt
export theme
set default=0
set timeout=3
extract_syslinux_entries_source -i /boot/syslinux/porteux.cfg
menuentry " " --hidden --hotkey=f1 {
	set theme=$prefix/help.txt
	configfile $prefix/helpmenu.cfg
	set theme=$prefix/menu.txt
}
EOF

cat > theme/helpmenu.cfg <<'EOF'
menuentry " " --hotkey=f1 {
	true
}
EOF

mkdir -p memdisk/boot/grub
cp theme/* memdisk/boot/grub/
tar -C memdisk -cf memdisk.tar boot || exit 1

MODULES="memdisk tar normal configfile search_fs_file regexp part_msdos part_gpt fat iso9660 linux font gfxterm gfxmenu png syslinuxcfg test true"

"$BUILD_PATH/i386-efi/bin/grub-mkimage" -d "$BUILD_PATH/i386-efi/lib/grub/i386-efi" -O i386-efi -o bootia32.efi -p /boot/grub -c early.cfg -m memdisk.tar $MODULES efi_gop efi_uga || exit 1
"$BUILD_PATH/x86_64-efi/bin/grub-mkimage" -d "$BUILD_PATH/x86_64-efi/lib/grub/x86_64-efi" -O x86_64-efi -o bootx64.efi -p /boot/grub -c early.cfg -m memdisk.tar $MODULES efi_gop efi_uga || exit 1
"$BUILD_PATH/i386-pc/bin/grub-mkimage" -d "$BUILD_PATH/i386-pc/lib/grub/i386-pc" -O i386-pc-eltorito -o eltorito.img -p /boot/grub -c early.cfg -m memdisk.tar $MODULES biosdisk linux16 vbe || exit 1
"$BUILD_PATH/i386-pc/bin/grub-mkimage" -d "$BUILD_PATH/i386-pc/lib/grub/i386-pc" -O i386-pc -o core.img -p /boot/grub -c early.cfg -m memdisk.tar $MODULES biosdisk linux16 vbe exfat ntfs ext2 btrfs xfs || exit 1

efi_image_kilobytes=$(( (($(stat -c %s bootx64.efi) + $(stat -c %s bootia32.efi)) / 1024 + 128 + 31) / 32 * 32 ))
truncate -s ${efi_image_kilobytes}K efi.img
mformat -i efi.img -T $((efi_image_kilobytes * 2)) -h 2 -s 32 :: || exit 1
mmd -i efi.img ::/EFI ::/EFI/BOOT || exit 1
mcopy -i efi.img bootx64.efi bootia32.efi ::/EFI/BOOT/ || exit 1

mkdir -p "$ISO_PATH/EFI/BOOT" "$ISO_PATH/boot/grub"
cp bootx64.efi bootia32.efi "$ISO_PATH/EFI/BOOT/" || exit 1
cp eltorito.img efi.img core.img "$BUILD_PATH/i386-pc/lib/grub/i386-pc/boot_hybrid.img" "$BUILD_PATH/i386-pc/lib/grub/i386-pc/boot.img" "$ISO_PATH/boot/grub/" || exit 1
chmod 755 "$ISO_PATH"/EFI/BOOT/* "$ISO_PATH"/boot/grub/*

echo "Finished successfully."
