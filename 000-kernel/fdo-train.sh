#!/bin/bash

source "$(dirname "$0")/../builder-utils/set-flags.sh"
set_flags "000-kernel"

source "$BUILDER_UTILS_PATH/helper.sh"
elevate_if_needed "$0" "$@"

VMLINUX=$SCRIPT_PATH/vmlinux-fdo-train
CACHE=$SCRIPT_PATH/fdo-train-cache
TOOLS=$CACHE/tools
LLVM=$TOOLS/llvm
DL=$CACHE/downloads
WORK=$CACHE/work
LOG=$CACHE/train.log
MODULE_PATH=$DL

source "$BUILDER_UTILS_PATH/slackware-repository.sh"
source "$BUILDER_UTILS_PATH/latest-from-github.sh"

for command in git wget curl unzip ffmpeg python3 nm strings make gcc whisper-cli librewolf mpv; do
	command -v "$command" > /dev/null || { echo "Missing $command. Install it and run again."; exit 1; }
done
[ -f "$VMLINUX" ] || { echo "Missing $VMLINUX. Build and boot the training kernel first: CLANG=yes AFDO=train ./create-module.sh"; exit 1; }
strings "$VMLINUX" | grep -qxF "$(uname -v)" || { echo "The running kernel is not the training kernel built with AFDO=train."; exit 1; }
kernel_tarball=$(ls "$SCRIPT_PATH"/linux-"$KERNEL_VERSION".tar.?z 2> /dev/null | head -n1)
[ -n "$kernel_tarball" ] || { echo "Missing linux-$KERNEL_VERSION source tarball in $SCRIPT_PATH."; exit 1; }
trap '' HUP

mkdir -p "$TOOLS" "$DL" "$WORK"

desktop_user=
desktop_env=$CACHE/desktop.env
for e in $(grep -lzE '^(WAYLAND_DISPLAY|DISPLAY)=' /proc/[0-9]*/environ 2> /dev/null); do
	owner=$(stat -c %U "$e" 2> /dev/null)
	[ -n "$owner" ] && [ "$owner" != root ] || continue
	mapfile -t vars < <(tr '\0' '\n' < "$e" 2> /dev/null | grep -E '^(WAYLAND_DISPLAY|DISPLAY|XDG_RUNTIME_DIR|XAUTHORITY|DBUS_SESSION_BUS_ADDRESS|XDG_SESSION_TYPE|XDG_CURRENT_DESKTOP)=')
	printf 'export %q\n' "${vars[@]}" > "$desktop_env"
	desktop_user=$owner
	break
done
[ -n "$desktop_user" ] || { echo "No desktop session found. Log in to the desktop and run again."; exit 1; }

if grep -q AuthenticAMD /proc/cpuinfo; then
	event=rc4:k
elif [ -d /sys/bus/event_source/devices/cpu_core ]; then
	event=cpu_core/event=0xc4,umask=0x20/k
else
	event=cpu/event=0xc4,umask=0x20/k
fi

echo "Preparing tools..."

if [ ! -x "$TOOLS/perf" ]; then
	echo "Building perf..."
	rm -fr "$WORK/perf" && mkdir -p "$WORK/perf"
	tar xf "$kernel_tarball" -C "$WORK/perf" || exit 1
	make -C "$WORK"/perf/linux-*/tools/perf -j"$NUMBER_THREADS" NO_LIBPYTHON=1 NO_LIBTRACEEVENT=1 NO_JEVENTS=1 NO_LIBPERL=1 NO_GTK2=1 NO_SDT=1 NO_LIBBPF=1 BUILD_BPF_SKEL=0 NO_SHELLCHECK=1 > "$WORK/perf/make.log" 2>&1 || { tail -20 "$WORK/perf/make.log"; exit 1; }
	cp "$WORK"/perf/linux-*/tools/perf/perf "$TOOLS/perf" || exit 1
	rm -fr "$WORK/perf"
fi

if [ ! -x "$LLVM/usr/bin/clang" ]; then
	echo "Downloading LLVM..."
	generate_repository_urls
	download_package "llvm"
	rm -fr "$LLVM" && mkdir -p "$LLVM"
	ROOT="$LLVM" installpkg "$DL"/packages/llvm-[0-9]*.txz > /dev/null && rm -f "$DL"/packages/llvm-[0-9]*.txz || exit 1
	[ -x "$LLVM/usr/bin/clang" ] && [ -x "$LLVM/usr/bin/ld.lld" ] || { echo "LLVM unpack failed."; exit 1; }
fi

if [ ! -x "$TOOLS/stress-ng" ]; then
	echo "Building stress-ng..."
	rm -fr /tmp/fdo-stress && mkdir -p /tmp/fdo-stress
	(cd /tmp/fdo-stress && info=$(download_latest_from_github "ColinIanKing" "stress-ng") && tar xf "${info% *}" && cd stress-ng-*/ && STATIC=1 make -j"$NUMBER_THREADS" && cp stress-ng "$TOOLS/stress-ng") > /tmp/fdo-stress.log 2>&1 || { tail -20 /tmp/fdo-stress.log; exit 1; }
	rm -fr /tmp/fdo-stress /tmp/fdo-stress.log
fi

if [ ! -x "$TOOLS/sysbench/bin/sysbench" ]; then
	echo "Building sysbench..."
	rm -fr /tmp/fdo-sysbench && mkdir -p /tmp/fdo-sysbench
	(cd /tmp/fdo-sysbench && info=$(download_latest_from_github "akopytov" "sysbench") && tar xf "${info% *}" && cd sysbench-*/ && ./autogen.sh && ./configure --without-mysql --prefix="$TOOLS/sysbench" && make -j"$NUMBER_THREADS" && make install) > /tmp/fdo-sysbench.log 2>&1 || { tail -20 /tmp/fdo-sysbench.log; exit 1; }
	rm -fr /tmp/fdo-sysbench /tmp/fdo-sysbench.log
fi

if [ ! -x "$TOOLS/schbench" ]; then
	echo "Building schbench..."
	rm -fr /tmp/fdo-schbench
	git clone -q --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/mason/schbench.git /tmp/fdo-schbench || { echo "schbench download failed."; exit 1; }
	make -C /tmp/fdo-schbench > /dev/null 2>&1 || { echo "schbench build failed."; exit 1; }
	cp /tmp/fdo-schbench/schbench "$TOOLS/schbench" || exit 1
	rm -fr /tmp/fdo-schbench
fi

if [ ! -x "$TOOLS/c-ray/c-ray-mt" ]; then
	echo "Building c-ray..."
	rm -fr /tmp/fdo-cray && mkdir -p /tmp/fdo-cray
	wget -q -O /tmp/fdo-cray/c-ray.tar.gz https://github.com/jtsiomb/c-ray/releases/download/c-ray-1.1/c-ray-1.1.tar.gz || { echo "c-ray download failed."; exit 1; }
	tar xzf /tmp/fdo-cray/c-ray.tar.gz -C /tmp/fdo-cray || exit 1
	make -C /tmp/fdo-cray/c-ray-1.1 clean > /dev/null && make -C /tmp/fdo-cray/c-ray-1.1 > /dev/null || exit 1
	mkdir -p "$TOOLS/c-ray"
	cp /tmp/fdo-cray/c-ray-1.1/c-ray-mt /tmp/fdo-cray/c-ray-1.1/sphfract "$TOOLS/c-ray/" || exit 1
	rm -fr /tmp/fdo-cray
fi

if [ ! -f "$DL/ggml-small.en.bin" ]; then
	echo "Downloading whisper model..."
	wget -q -O "$DL/ggml-small.en.bin" https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin || { rm -f "$DL/ggml-small.en.bin"; echo "whisper model download failed."; exit 1; }
fi
if [ ! -f "$DL/speech-60s.wav" ]; then
	wget -q -O "$DL/jfk.wav" https://github.com/ggml-org/whisper.cpp/raw/master/samples/jfk.wav || { echo "audio download failed."; exit 1; }
	ffmpeg -loglevel error -y -stream_loop 5 -i "$DL/jfk.wav" -t 60 -ar 16000 -ac 1 -c:a pcm_s16le "$DL/speech-60s.wav" || exit 1
	rm -f "$DL/jfk.wav"
fi

if [ ! -x "$TOOLS/wmbench/tools/usagebench" ]; then
	echo "Building wmbench..."
	rm -fr "$TOOLS/wmbench"
	git clone -q --depth 1 https://github.com/fulalas/wmbench "$TOOLS/wmbench" || { echo "wmbench download failed."; exit 1; }
	make -C "$TOOLS/wmbench" > /dev/null 2>&1 || { rm -fr "$TOOLS/wmbench"; echo "wmbench build failed."; exit 1; }
fi
chown -R "$desktop_user" "$TOOLS/wmbench" 2> /dev/null

if [ ! -f "$TOOLS/speedometer/index.html" ]; then
	echo "Downloading Speedometer 3.1..."
	rm -fr "$TOOLS/speedometer"
	git clone -q --depth 1 -b release/3.1 https://github.com/WebKit/Speedometer "$TOOLS/speedometer" || { echo "Speedometer download failed."; exit 1; }
	rm -fr "$TOOLS/speedometer/.git"
	sed -i 's|<script src="resources/main.mjs" type="module"></script>|&\n        <script type="module">\n            const client = globalThis.benchmarkClient;\n            const finish = client.didFinishLastIteration.bind(client);\n            client.didFinishLastIteration = (metrics) => { finish(metrics); fetch("/fdo-done"); };\n            const fail = client.handleError.bind(client);\n            client.handleError = (error) => { fail(error); fetch("/fdo-done"); };\n        </script>|' "$TOOLS/speedometer/index.html"
	grep -q fdo-done "$TOOLS/speedometer/index.html" || { rm -fr "$TOOLS/speedometer"; echo "Failed to add the end hook to Speedometer."; exit 1; }
	chmod -R a+rX "$TOOLS/speedometer"
fi

if [ ! -f "$DL/bbb-1080p60.mp4" ]; then
	echo "Downloading the test video..."
	wget -q -O "$DL/bbb.zip" https://download.blender.org/demo/movies/BBB/bbb_sunflower_1080p_60fps_normal.mp4.zip || { echo "video download failed."; exit 1; }
	unzip -o -q "$DL/bbb.zip" -d "$DL/bbb" && mv "$DL"/bbb/*.mp4 "$DL/bbb-1080p60.mp4" && rm -fr "$DL/bbb.zip" "$DL/bbb" || exit 1
	chmod a+r "$DL/bbb-1080p60.mp4"
fi

"$TOOLS/perf" record -e "$event" -b -a -N -c 500009 -o /tmp/fdo-lbrtest.data -- sleep 1 > /tmp/fdo-lbrtest.log 2>&1 || { cat /tmp/fdo-lbrtest.log; echo "This CPU can't record branch stacks (LBR)."; exit 1; }
rm -f /tmp/fdo-lbrtest.data /tmp/fdo-lbrtest.log

browser_profile=$(su -s /bin/bash "$desktop_user" -c "mktemp -d /tmp/fdo-librewolf.XXXXXX")
[ -d "$browser_profile" ] || { echo "Failed to create a browser profile."; exit 1; }
su -s /bin/bash "$desktop_user" -c "printf '%s\n' 'user_pref(\"privacy.resistFingerprinting\", false);' 'user_pref(\"privacy.fingerprintingProtection\", false);' 'user_pref(\"privacy.reduceTimerPrecision\", false);' 'user_pref(\"browser.shell.checkDefaultBrowser\", false);' 'user_pref(\"browser.aboutwelcome.enabled\", false);' 'user_pref(\"app.update.enabled\", false);' > '$browser_profile/user.js'"

echo "Recording. This takes about 30 minutes. Don't use the PC meanwhile."
: > "$LOG"
rm -f "$CACHE/perf.data"
"$TOOLS/perf" record -e "$event" -b -a -N -c 166667 -o "$CACHE/perf.data" > "$CACHE/perf-record.log" 2>&1 &
perf_pid=$!
trap 'kill -INT "$perf_pid" 2> /dev/null; rm -fr "$browser_profile"' EXIT
sleep 2
kill -0 "$perf_pid" 2> /dev/null || { tail -20 "$CACHE/perf-record.log"; echo "perf failed to start."; exit 1; }

echo "[$(date +%T)] stress-ng" | tee -a "$LOG"
mkdir -p "$WORK/stress" && cd "$WORK/stress" || exit 1
for s in switch pipe futex sem sem-sysv msg mq fork clone vfork mmap fault brk open dentry rename getdent link sock udp sockpair epoll poll sigq get memfd inotify hdd splice timerfd eventfd yield; do
	"$TOOLS/stress-ng" --$s "$NUMBER_THREADS" --mmap-bytes 32M --hdd-bytes 32M --timeout 6 --temp-path "$WORK/stress" >> "$LOG" 2>&1
done
cd / && rm -fr "$WORK/stress"

echo "[$(date +%T)] perf bench" | tee -a "$LOG"
"$TOOLS/perf" bench sched messaging -g 20 -l 1000 >> "$LOG" 2>&1
"$TOOLS/perf" bench sched pipe -l 1000000 >> "$LOG" 2>&1
"$TOOLS/perf" bench futex hash -r 5 >> "$LOG" 2>&1
"$TOOLS/perf" bench futex wake >> "$LOG" 2>&1
"$TOOLS/perf" bench futex lock-pi -r 5 >> "$LOG" 2>&1
"$TOOLS/perf" bench syscall basic -l 10000000 >> "$LOG" 2>&1
"$TOOLS/perf" bench epoll wait -r 5 >> "$LOG" 2>&1
"$TOOLS/perf" bench epoll ctl -r 5 >> "$LOG" 2>&1
"$TOOLS/perf" bench mem memcpy -f default -s 1GB >> "$LOG" 2>&1
"$TOOLS/perf" bench mem memset -f default -s 1GB >> "$LOG" 2>&1

echo "[$(date +%T)] sysbench and schbench" | tee -a "$LOG"
"$TOOLS/sysbench/bin/sysbench" memory --memory-block-size=1M --memory-total-size=16G --threads="$NUMBER_THREADS" run >> "$LOG" 2>&1
mkdir -p "$WORK/fileio" && cd "$WORK/fileio" || exit 1
"$TOOLS/sysbench/bin/sysbench" fileio --file-total-size=4G --file-num=4 prepare >> "$LOG" 2>&1
sync && echo 3 > /proc/sys/vm/drop_caches
"$TOOLS/sysbench/bin/sysbench" fileio --file-total-size=4G --file-num=4 --file-fsync-freq=0 --file-test-mode=rndrd --file-block-size=4K --time=20 run >> "$LOG" 2>&1
"$TOOLS/sysbench/bin/sysbench" fileio --file-total-size=4G --file-num=4 --file-fsync-freq=0 --file-test-mode=seqwr --file-block-size=1M --time=20 run >> "$LOG" 2>&1
"$TOOLS/sysbench/bin/sysbench" fileio --file-total-size=4G --file-num=4 cleanup >> "$LOG" 2>&1
cd / && rm -fr "$WORK/fileio"
"$TOOLS/schbench" -m 2 -r 30 >> "$LOG" 2>&1

echo "[$(date +%T)] kernel builds" | tee -a "$LOG"
rm -fr /tmp/fdo-kbuild && mkdir -p /tmp/fdo-kbuild
tar xf "$kernel_tarball" -C /tmp/fdo-kbuild
(
	export PATH="$LLVM/usr/bin:$PATH" LD_LIBRARY_PATH="$LLVM/usr/lib64"
	cd /tmp/fdo-kbuild/linux-* || exit 1
	make ARCH=x86_64 LLVM=1 tinyconfig > /dev/null 2>&1
	make ARCH=x86_64 LLVM=1 -j"$NUMBER_THREADS" bzImage
	make mrproper > /dev/null 2>&1
	cp "$SCRIPT_PATH/64bit.config" .config
	make LLVM=1 olddefconfig > /dev/null 2>&1
	make LLVM=1 -j"$NUMBER_THREADS" bzImage
) >> "$LOG" 2>&1
rm -fr /tmp/fdo-kbuild

echo "[$(date +%T)] disk file work" | tee -a "$LOG"
rm -fr "$WORK/files" && mkdir -p "$WORK/files"
sync && echo 3 > /proc/sys/vm/drop_caches
tar xf "$kernel_tarball" -C "$WORK/files"
sync && echo 3 > /proc/sys/vm/drop_caches
cp -a "$WORK"/files/linux-* "$WORK/files/copy"
sync && echo 3 > /proc/sys/vm/drop_caches
grep -r -c -I spin_lock "$WORK/files/copy" > /dev/null
find "$WORK/files" -name '*.c' -size +10k > /dev/null
rm -fr "$WORK/files"
sync
rm -fr /var/tmp/fdo-files && mkdir -p /var/tmp/fdo-files
tar xf "$kernel_tarball" -C /var/tmp/fdo-files
grep -r -c -I spin_lock /var/tmp/fdo-files > /dev/null
find /var/tmp/fdo-files -name '*.c' -size +10k > /dev/null
rm -fr /var/tmp/fdo-files
sync

echo "[$(date +%T)] network download" | tee -a "$LOG"
for v in 6.12 6.6 6.1; do
	curl -s -o "$WORK/download.tmp" https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$v.tar.xz
	rm -f "$WORK/download.tmp"
done

echo "[$(date +%T)] c-ray" | tee -a "$LOG"
"$TOOLS/c-ray/c-ray-mt" -t $((NUMBER_THREADS * 2)) -s 3840x2160 -r 8 -i "$TOOLS/c-ray/sphfract" -o /dev/null >> "$LOG" 2>&1

echo "[$(date +%T)] whisper" | tee -a "$LOG"
whisper-cli -ng -np -t "$NUMBER_THREADS" -m "$DL/ggml-small.en.bin" -f "$DL/speech-60s.wav" > /dev/null 2>> "$LOG"

echo "[$(date +%T)] wmbench" | tee -a "$LOG"
su -s /bin/bash "$desktop_user" -c "source '$desktop_env' && cd '$TOOLS/wmbench' && ./benchmark.sh" >> "$LOG" 2>&1

echo "[$(date +%T)] Speedometer in LibreWolf" | tee -a "$LOG"
python3 -I -m http.server 8642 --bind 127.0.0.1 --directory "$TOOLS/speedometer" > "$CACHE/http.log" 2>&1 &
http_pid=$!
su -s /bin/bash "$desktop_user" -c "source '$desktop_env' && exec librewolf --no-remote --profile '$browser_profile' 'http://127.0.0.1:8642/index.html?iterationCount=5&startAutomatically'" >> "$LOG" 2>&1 &
browser_pid=$!
for i in $(seq 1 900); do
	grep -aq fdo-done "$CACHE/http.log" && break
	kill -0 "$browser_pid" 2> /dev/null || break
	sleep 1
done
grep -aq fdo-done "$CACHE/http.log" || echo "  Speedometer did not finish" | tee -a "$LOG"
pkill -u "$desktop_user" -f -- "--profile $browser_profile"
sleep 2
kill "$http_pid" 2> /dev/null
rm -fr "$browser_profile"

echo "[$(date +%T)] mpv" | tee -a "$LOG"
su -s /bin/bash "$desktop_user" -c "source '$desktop_env' && mpv --no-config --hwdec=auto --fs --length=60 --volume=0 --really-quiet '$DL/bbb-1080p60.mp4'" >> "$LOG" 2>&1

kill -INT "$perf_pid"
wait "$perf_pid"
trap - EXIT
rm -fr "$WORK"
echo "[$(date +%T)] recording done" | tee -a "$LOG"

echo "Creating the profile..."
read -r text etext < <(nm "$VMLINUX" | awk '$3 == "_text" { t = $1 } $3 == "_etext" { e = $1 } END { print t, e }')
[ -n "$text" ] && [ -n "$etext" ] || { echo "Can't find _text/_etext in $VMLINUX."; exit 1; }
{
	echo "PERF_RECORD_MMAP -1/0: [0x$text($(printf '0x%x' $(( 0x$etext - 0x$text )))) @ 0x$text]: x [kernel.kallsyms]_text"
	"$TOOLS/perf" script -f -i "$CACHE/perf.data" -F ip,brstack 2> /dev/null
} > "$CACHE/perf.script" || exit 1
LD_LIBRARY_PATH=$LLVM/usr/lib64 "$LLVM/usr/bin/llvm-profgen" --kernel --binary="$VMLINUX" --perfscript="$CACHE/perf.script" -o "$CACHE/kernel.afdo" > "$CACHE/profgen.log" 2>&1 || { tail -20 "$CACHE/profgen.log"; exit 1; }
LD_LIBRARY_PATH=$LLVM/usr/lib64 "$LLVM/usr/bin/llvm-profdata" show --sample "$CACHE/kernel.afdo" > /dev/null 2>&1 || { echo "The new profile is not valid."; exit 1; }
[ "$(stat -c %s "$CACHE/kernel.afdo")" -gt 100000 ] || { echo "The new profile is too small."; exit 1; }

cp "$CACHE/kernel.afdo" "$SCRIPT_PATH/kernel.afdo" || exit 1
uname -r > "$SCRIPT_PATH/kernel.afdo.version"
rm -f "$CACHE/perf.data" "$CACHE/perf.script"
echo "Done. New profile: $SCRIPT_PATH/kernel.afdo (trained on $(uname -r))"
echo "Next: boot any kernel and run CLANG=yes ./create-module.sh"
