#!/bin/bash
source "$BUILDER_UTILS_PATH/slackware-repository.sh"

generate_repository_urls

download_package "aaa_base" &
download_package "aaa_terminfo" &
download_package "acl" &
download_package "acpid" &
download_package "attr" &
download_package "avahi" &
download_package "bash" &
download_package "bc" & # to perform arithmetic operations in bash
download_package "bin" &
download_package "bluez" &
wait
download_package "bluez-firmware" &
download_package "bridge-utils" &
download_package "brotli" &
download_package "btrfs-progs" &
download_package "bzip2" &
download_package "ca-certificates" &
download_package "cdrtools" &
download_package "cifs-utils" &
download_package "cpio" &
download_package "curl" &
wait
download_package "cyrus-sasl" &
download_package "dbus" &
download_package "dbus-glib" &
download_package "dbus-python" & # required by TLP (via AppStore)
download_package "dcron" &
download_package "devs" &
download_package "dhcpcd" &
download_package "dialog" &
download_package "diffutils" &
download_package "dmapi" &
wait
download_package "dmidecode" &
download_package "dnsmasq" &
download_package "dosfstools" &
download_package "dvd+rw-tools" &
download_package "e2fsprogs" &
download_package "elfutils" &
download_package "elogind" &
download_package "etc" &
download_package "ethtool" &
download_package "eudev" &
wait
download_package "exfatprogs" &
download_package "expat" &
download_package "f2fs-tools" &
download_package "file" &
download_package "findutils" &
download_package "flex" &
download_package "floppy" &
download_package "fuse3" &
download_package "gawk" &
download_package "gd" &
wait
download_package "gdbm" &
download_package "gettext" &
download_package "glib2" &
download_package "glibc-zoneinfo" &
download_package "gnupg" &
download_package "gnutls" &
download_package "gpgme" &
download_package "gpm" &
download_package "gptfdisk" &
download_package "grep" &
wait
download_package "gzip" &
download_package "hdparm" &
download_package "hostname" &
download_package "icu4c" &
download_package "infozip" &
download_package "inih" &
download_package "iproute2" &
download_package "iptables" &
download_package "iputils" &
download_package "iw" &
wait
download_package "jansson" &
download_package "kbd" &
download_package "keyutils" &
download_package "kmod" &
download_package "less" &
download_package "libaio" &
download_package "libarchive" &
download_package "libassuan" &
download_package "libcap" &
download_package "libcap-ng" &
wait
download_package "libffi" &
download_package "libgcrypt" &
download_package "libgpg-error" &
download_package "libgudev" &
download_package "libidn" &
download_package "libidn2" &
download_package "libimobiledevice" &
download_package "libimobiledevice-glue" &
download_package "libldap" &
download_package "libmbim" &
wait
download_package "libmnl" &
download_package "libndp" &
download_package "libnetfilter_conntrack" &
download_package "libnfnetlink" &
download_package "libnftnl" &
download_package "libnih" &
download_package "libnl3" &
download_package "libnsl" &
download_package "libpcap" &
download_package "libplist" &
wait
download_package "libpsl" &
download_package "libqmi" &
download_package "libqrtr-glib" & # required by libqmi, ModemManager
download_package "libraw1394" &
download_package "libseccomp" &
download_package "libssh2" &
download_package "libtasn1" &
download_package "libtirpc" &
download_package "libunistring" &
download_package "liburing" & # required by samba
wait
download_package "libusb" &
download_package "libusb-compat" &
download_package "libusbmuxd" &
download_package "libxml2" &
download_package "libzip" &
download_package "lmdb" &
download_package "lm_sensors" &
download_package "lsof" &
download_package "lua" &
download_package "lvm2" &
wait
download_package "lynx" &
download_package "lz4" &
download_package "lzip" &
download_package "lzlib" &
download_package "lzo" &
download_package "mc" &
download_package "mdadm" &
download_package "mlocate" &
download_package "ModemManager" &
download_package "mozilla-nss" &
wait
download_package "mpfr" &
download_package "nano" &
download_package "ncurses" &
download_package "nettle" &
download_package "net-tools" &
download_package "NetworkManager" &
download_package "network-scripts" &
download_package "newt" &
download_package "nfs-utils" &
download_package "nghttp2" &
wait
download_package "nghttp3" &
download_package "ngtcp2" &
download_package "openssh" &
download_package "openssl" &
download_package "openvpn" &
download_package "p11-kit" &
download_package "pam" &
download_package "parted" &
download_package "patch" &
download_package "pciutils" &
wait
download_package "pcre" &
download_package "pcre2" &
download_package "pkgtools" &
download_package "popt" &
download_package "ppp" &
download_package "pptp" &
download_package "python3" &
download_package "python-urllib3" &
download_package "readline" &
download_package "rpcbind" &
wait
download_package "rpm2tgz" &
download_package "rp-pppoe" &
download_package "rsync" &
download_package "samba" &
download_package "sdparm" &
download_package "sed" &
download_package "sg3_utils" &
download_package "shadow" &
download_package "slackpkg" &
download_package "smartmontools" &
wait
download_package "sqlite" &
download_package "sshfs" &
download_package "sudo" &
download_package "sysfsutils" &
download_package "sysklogd" &
download_package "sysvinit-functions" &
download_package "sysvinit-scripts" &
download_package "talloc" &
download_package "tar" &
download_package "tcl" &
wait
download_package "tdb" &
download_package "telnet" &
download_package "tevent" &
download_package "traceroute" &
download_package "uring" &
download_package "usb_modeswitch" &
download_package "usbmuxd" &
download_package "usbutils" &
download_package "userspace-rcu" &
download_package "utempter" &
wait
download_package "util-linux" &
download_package "wget" &
download_package "which" &
download_package "whois" &
download_package "wireless_tools" &
download_package "wpa_supplicant" &
download_package "xfsdump" &
download_package "xfsprogs" &
download_package "xxHash" &
download_package "xz" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && download_package "llvm" &
wait

### packages that require specific stripping

download_package "aaa_libraries" &
download_package "binutils" &
download_package "fftw" & # required by pulse plugins
download_package "gcc-g++" & # required by aaa_libraries
download_package "gcc" & # required by aaa_libraries
download_package "ntp" &
download_package "openldap" &
wait

### script clean up

rm FILE_LIST
rm server-packages.txt
