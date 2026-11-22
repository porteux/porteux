#!/bin/bash

GRUB_VERSION="2.14"
KBD_VERSION="2.10.0"

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
ISO_PATH="$(readlink -f "$SCRIPT_PATH/../iso")"
BOOT_FILES_PATH="$ISO_PATH/boot/porteux"
BUILD_PATH="$(mktemp -d)"
trap 'rm -rf "$BUILD_PATH"' EXIT
MEMDISK_PATH=memdisk/boot/grub

for tool in gcc make bison flex python3 patch mformat mmd mcopy wget; do
	command -v $tool > /dev/null 2>&1 || { echo "Required tool not found: $tool"; exit 1; }
done

cd "$BUILD_PATH" || exit 1

wget -q "https://ftp.gnu.org/gnu/grub/grub-${GRUB_VERSION}.tar.xz" || { echo "Failed to download grub."; exit 1; }
wget -q "https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-${KBD_VERSION}.tar.xz" || { echo "Failed to download kbd."; exit 1; }
tar xf grub-${GRUB_VERSION}.tar.xz || exit 1
tar xf kbd-${KBD_VERSION}.tar.xz kbd-${KBD_VERSION}/data/consolefonts/cp865-8x16.psfu || exit 1

for grub_patch in "$SCRIPT_PATH"/patches/grub-*.patch; do
	patch -d grub-${GRUB_VERSION} -p1 < "$grub_patch" > /dev/null || { echo "Failed to apply $grub_patch."; exit 1; }
done

for platform in i386-efi x86_64-efi i386-pc; do
	echo "Building grub for $platform..."
	mkdir -p build-$platform
	cd build-$platform || exit 1
	../grub-${GRUB_VERSION}/configure --prefix="$BUILD_PATH/$platform" --target=${platform%%-*} --with-platform=${platform#*-} --disable-werror ax_cv_check_ldflags___Wl___image_base_0x400000=no > /dev/null 2>&1 || { echo "Failed to configure grub for $platform."; exit 1; }
	make -j$(nproc) > /dev/null 2>&1 || { echo "Failed to build grub for $platform."; exit 1; }
	make install > /dev/null 2>&1 || { echo "Failed to install grub for $platform."; exit 1; }
	cd .. || exit 1
done

[ -x "$BUILD_PATH/i386-efi/bin/grub-mkfont" ] || { echo "grub-mkfont was not built. Install freetype development files."; exit 1; }

mkdir -p "$MEMDISK_PATH"

python3 -I - kbd-${KBD_VERSION}/data/consolefonts/cp865-8x16.psfu vga.bdf <<'EOF' || { echo "Failed to convert font."; exit 1; }
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
"$BUILD_PATH/i386-efi/bin/grub-mkfont" -o "$MEMDISK_PATH"/vga.pf2 vga.bdf > /dev/null 2>&1 || { echo "Failed to create grub font."; exit 1; }

logo_component=$(python3 -I - "$MEMDISK_PATH" "$BOOT_FILES_PATH/bootlogo.png" <<'EOF'
import struct, sys, zlib
def chunk(kind, data):
	return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data) & 0xffffffff)
def write_png(name, width, height, color_type, rows):
	bpp = 3 if color_type == 2 else 4
	raw = b''
	previous = bytes(len(rows[0]))
	for row in rows:
		candidates = []
		for kind in range(5):
			filtered = bytearray(len(row))
			for i in range(len(row)):
				left = row[i - bpp] if i >= bpp else 0
				up = previous[i]
				upper_left = previous[i - bpp] if i >= bpp else 0
				if kind == 0:
					predictor = 0
				elif kind == 1:
					predictor = left
				elif kind == 2:
					predictor = up
				elif kind == 3:
					predictor = (left + up) // 2
				else:
					estimate = left + up - upper_left
					pa, pb, pc = abs(estimate - left), abs(estimate - up), abs(estimate - upper_left)
					predictor = left if pa <= pb and pa <= pc else up if pb <= pc else upper_left
				filtered[i] = (row[i] - predictor) & 255
			candidates.append((sum(v if v < 128 else 256 - v for v in filtered), kind, bytes(filtered)))
		score, kind, filtered = min(candidates)
		raw += bytes([kind]) + filtered
		previous = row
	png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, color_type, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b'')
	open(sys.argv[1] + '/' + name, 'wb').write(png)
for name, color, width in (('sel_c.png', (0x00, 0x96, 0xff), 1), ('sel_w.png', (0x00, 0x96, 0xff), 8)):
	write_png(name, width, 1, 2, [bytes(color) * width])
data = open(sys.argv[2], 'rb').read()
position = 8
idat = b''
while position < len(data):
	length, kind = struct.unpack('>I4s', data[position:position + 8])
	body = data[position + 8:position + 8 + length]
	if kind == b'IHDR':
		width, height, depth, color_type, compression, filtering, interlace = struct.unpack('>IIBBBBB', body)
	elif kind == b'IDAT':
		idat += body
	position += 12 + length
if depth != 8 or color_type not in (2, 6) or interlace:
	sys.exit('bootlogo.png must be an 8-bit RGB or RGBA non-interlaced PNG')
bpp = 3 if color_type == 2 else 4
stride = width * bpp
raw = zlib.decompress(idat)
rows = []
previous = bytearray(stride)
for y in range(height):
	kind = raw[y * (stride + 1)]
	row = bytearray(raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)])
	for i in range(stride):
		left = row[i - bpp] if i >= bpp else 0
		up = previous[i]
		upper_left = previous[i - bpp] if i >= bpp else 0
		if kind == 1:
			row[i] = (row[i] + left) & 255
		elif kind == 2:
			row[i] = (row[i] + up) & 255
		elif kind == 3:
			row[i] = (row[i] + (left + up) // 2) & 255
		elif kind == 4:
			estimate = left + up - upper_left
			pa, pb, pc = abs(estimate - left), abs(estimate - up), abs(estimate - upper_left)
			row[i] = (row[i] + (left if pa <= pb and pa <= pc else up if pb <= pc else upper_left)) & 255
	rows.append(bytes(row))
	previous = row
def is_background(row, x):
	return row[x * bpp + 3] == 0 if bpp == 4 else row[x * bpp:(x + 1) * bpp] == b'\0\0\0'
used_rows = [y for y in range(height) if not all(is_background(rows[y], x) for x in range(width))]
if not used_rows:
	sys.exit('bootlogo.png is empty')
used_columns = [x for x in range(width) if not all(is_background(rows[y], x) for y in used_rows)]
x0, x1, y0, y1 = used_columns[0], used_columns[-1] + 1, used_rows[0], used_rows[-1] + 1
write_png('bootlogo.png', x1 - x0, y1 - y0, color_type, [rows[y][x0 * bpp:x1 * bpp] for y in range(y0, y1)])
print('+ image { left = "50%%%+d" top = "50%%%+d" width = %d height = %d file = "bootlogo.png" }' % (x0 - width // 2, y0 - height // 2, x1 - x0, y1 - y0))
EOF
) || { echo "Failed to create theme images."; exit 1; }

{
	echo 'title-text: ""'
	echo 'desktop-color: "#000000"'
	echo "$logo_component"
	cat <<'EOF'
terminal-font: "vga Regular 16"
terminal-border: "0"
terminal-left: "8"
terminal-top: "100%-40"
terminal-width: "100%-16"
terminal-height: "32"
+ label { id = "__timeout__" left = "50%-200" top = "100%-56" width = 328 height = 16 font = "vga Regular 16" color = "#bcbcbc" text = "Press Esc for options, automatic boot in " }
+ label { id = "__timeout__" left = "50%+128" top = "100%-56" width = 8 height = 16 font = "vga Regular 16" color = "#e1e1e1" text = "%d" }
+ label { id = "__timeout__" left = "50%+136" top = "100%-56" width = 120 height = 16 font = "vga Regular 16" color = "#bcbcbc" text = " second(s)..." }
+ progress_bar { id = "__timeout__" left = "50%-296" top = "100%-120" width = 616 height = 96 fg_color = "#000000" bg_color = "#000000" border_color = "#000000" show_text = false }
+ boot_menu {
  left = "50%-96" top = "100%-120" width = 216 height = 80
  item_font = "vga Regular 16" selected_item_font = "vga Regular 16"
  item_color = "#ffffff" selected_item_color = "#ffffff"
  item_height = 16 item_padding = 0 item_spacing = 0
  icon_width = 0 icon_height = 0 item_icon_space = 0
  selected_item_pixmap_style = "sel_*.png"
  scrollbar = false scrollbar_left_pad = 0
}
+ label { left = "50%-296" top = "100%-40" width = 200 height = 16 font = "vga Regular 16" color = "#0096ff" text = "[F1] help" }
+ label { left = "50%+120" top = "100%-40" width = 200 height = 16 align = "right" font = "vga Regular 16" color = "#0096ff" text = "[Tab] edit >" }
EOF
} > "$MEMDISK_PATH"/menu.txt

{
	echo 'title-text: ""'
	echo 'desktop-color: "#000000"'
	line_number=0
	tr -d '\r' < "$BOOT_FILES_PATH/help.txt" | while IFS= read -r line; do
		line=${line//\"/\'}
		echo "+ label { left = 8 top = $((8 + 16 * line_number)) width = \"100%-16\" height = 16 font = \"vga Regular 16\" color = \"#c6c6c6\" text = \"$line\" }"
		line_number=$((line_number + 1))
	done
} > "$MEMDISK_PATH"/help.txt

cat > early.cfg <<'EOF'
if [ ! -f /boot/porteux/initrd.zst ]; then
	regexp --set=1:bootdisk '^\(([^,)]+)' "$cmdpath"
	search.file /boot/porteux/initrd.zst root "$bootdisk,"
fi
set prefix=(memdisk)/boot/grub
EOF

cat > "$MEMDISK_PATH"/grub.cfg <<'EOF'
loadfont $prefix/vga.pf2
set gfxmode=1024x768,auto
terminal_output gfxterm
set theme=$prefix/menu.txt
syslinux_source -i /boot/porteux/porteux.cfg
submenu " " --hidden --hotkey=f1 {
	set theme=$prefix/help.txt
	menuentry " " --hotkey=f1 {
		true
	}
}
EOF

tar -C memdisk -cf memdisk.tar boot || exit 1

MODULES="memdisk tar normal search_fs_file regexp part_msdos fat font gfxterm gfxmenu png syslinuxcfg test true"

for image in \
	"i386-efi bootia32.efi part_gpt iso9660 linux efi_gop efi_uga" \
	"x86_64-efi bootx64.efi part_gpt iso9660 linux efi_gop efi_uga" \
	"i386-pc-eltorito eltorito.img part_gpt iso9660 biosdisk linux16 vbe" \
	"i386-pc core.img biosdisk linux16 vbe exfat ntfs ext2 btrfs xfs" \
; do
	set -- $image
	format=$1
	platform=${format%-eltorito}
	output=$2
	shift 2
	"$BUILD_PATH/$platform/bin/grub-mkimage" -d "$BUILD_PATH/$platform/lib/grub/$platform" -O $format -o $output -p /boot/grub -c early.cfg -m memdisk.tar $MODULES "$@" || { echo "Failed to create $output."; exit 1; }
done

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
