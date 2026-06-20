#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

GenerateRepositoryUrls

DownloadPackage "aaa_base" &
DownloadPackage "aaa_terminfo" &
DownloadPackage "acl" &
DownloadPackage "acpid" &
DownloadPackage "attr" &
DownloadPackage "avahi" &
DownloadPackage "bash" &
DownloadPackage "bc" & # to perform arithmetic operations in bash
DownloadPackage "bin" &
DownloadPackage "bluez" &
wait
DownloadPackage "bluez-firmware" &
DownloadPackage "bridge-utils" &
DownloadPackage "brotli" &
DownloadPackage "btrfs-progs" &
DownloadPackage "bzip2" &
DownloadPackage "ca-certificates" &
DownloadPackage "cdrtools" &
DownloadPackage "cifs-utils" &
DownloadPackage "cpio" &
DownloadPackage "curl" &
wait
DownloadPackage "cyrus-sasl" &
DownloadPackage "dbus" &
DownloadPackage "dbus-glib" &
DownloadPackage "dbus-python" & # required by TLP (via AppStore)
DownloadPackage "dcron" &
DownloadPackage "devs" &
DownloadPackage "dhcpcd" &
DownloadPackage "dialog" &
DownloadPackage "diffutils" &
DownloadPackage "dmapi" &
wait
DownloadPackage "dmidecode" &
DownloadPackage "dnsmasq" &
DownloadPackage "dosfstools" &
DownloadPackage "dvd+rw-tools" &
DownloadPackage "e2fsprogs" &
DownloadPackage "elfutils" &
DownloadPackage "elogind" &
DownloadPackage "etc" &
DownloadPackage "ethtool" &
DownloadPackage "eudev" &
wait
DownloadPackage "exfatprogs" &
DownloadPackage "expat" &
DownloadPackage "f2fs-tools" &
DownloadPackage "file" &
DownloadPackage "findutils" &
DownloadPackage "flex" &
DownloadPackage "floppy" &
DownloadPackage "fuse3" &
DownloadPackage "gawk" &
DownloadPackage "gd" &
wait
DownloadPackage "gdbm" &
DownloadPackage "gettext" &
DownloadPackage "glib2" &
DownloadPackage "glibc-zoneinfo" &
DownloadPackage "gnupg" &
DownloadPackage "gnutls" &
DownloadPackage "gpgme" &
DownloadPackage "gpm" &
DownloadPackage "gptfdisk" &
DownloadPackage "grep" &
wait
DownloadPackage "gzip" &
DownloadPackage "hdparm" &
DownloadPackage "hostname" &
DownloadPackage "icu4c" &
DownloadPackage "infozip" &
DownloadPackage "inih" &
DownloadPackage "iproute2" &
DownloadPackage "iptables" &
DownloadPackage "iputils" &
DownloadPackage "iw" &
wait
DownloadPackage "jansson" &
DownloadPackage "kbd" &
DownloadPackage "keyutils" &
DownloadPackage "kmod" &
DownloadPackage "less" &
DownloadPackage "libaio" &
DownloadPackage "libarchive" &
DownloadPackage "libassuan" &
DownloadPackage "libcap" &
DownloadPackage "libcap-ng" &
wait
DownloadPackage "libffi" &
DownloadPackage "libgcrypt" &
DownloadPackage "libgpg-error" &
DownloadPackage "libgudev" &
DownloadPackage "libidn" &
DownloadPackage "libidn2" &
DownloadPackage "libimobiledevice" &
DownloadPackage "libimobiledevice-glue" &
DownloadPackage "libldap" &
DownloadPackage "libmbim" &
wait
DownloadPackage "libmnl" &
DownloadPackage "libndp" &
DownloadPackage "libnetfilter_conntrack" &
DownloadPackage "libnfnetlink" &
DownloadPackage "libnftnl" &
DownloadPackage "libnih" &
DownloadPackage "libnl3" &
DownloadPackage "libnsl" &
DownloadPackage "libpcap" &
DownloadPackage "libplist" &
wait
DownloadPackage "libpsl" &
DownloadPackage "libqmi" &
DownloadPackage "libqrtr-glib" & # required by libqmi, ModemManager
DownloadPackage "libraw1394" &
DownloadPackage "libseccomp" &
DownloadPackage "libssh2" &
DownloadPackage "libtasn1" &
DownloadPackage "libtirpc" &
DownloadPackage "libunistring" &
DownloadPackage "liburing" & # required by samba
wait
DownloadPackage "libusb" &
DownloadPackage "libusb-compat" &
DownloadPackage "libusbmuxd" &
DownloadPackage "libxml2" &
DownloadPackage "libzip" &
DownloadPackage "lmdb" &
DownloadPackage "lm_sensors" &
DownloadPackage "lsof" &
DownloadPackage "lua" &
DownloadPackage "lvm2" &
wait
DownloadPackage "lynx" &
DownloadPackage "lz4" &
DownloadPackage "lzip" &
DownloadPackage "lzlib" &
DownloadPackage "lzo" &
DownloadPackage "mc" &
DownloadPackage "mdadm" &
DownloadPackage "mlocate" &
DownloadPackage "ModemManager" &
DownloadPackage "mozilla-nss" &
wait
DownloadPackage "mpfr" &
DownloadPackage "nano" &
DownloadPackage "ncurses" &
DownloadPackage "nettle" &
DownloadPackage "net-tools" &
DownloadPackage "NetworkManager" &
DownloadPackage "network-scripts" &
DownloadPackage "newt" &
DownloadPackage "nfs-utils" &
DownloadPackage "nghttp2" &
wait
DownloadPackage "nghttp3" &
DownloadPackage "ngtcp2" &
DownloadPackage "openssh" &
DownloadPackage "openssl" &
DownloadPackage "openvpn" &
DownloadPackage "p11-kit" &
DownloadPackage "pam" &
DownloadPackage "parted" &
DownloadPackage "patch" &
DownloadPackage "pciutils" &
wait
DownloadPackage "pcre" &
DownloadPackage "pcre2" &
DownloadPackage "pkgtools" &
DownloadPackage "popt" &
DownloadPackage "ppp" &
DownloadPackage "pptp" &
DownloadPackage "python3" &
DownloadPackage "python-urllib3" &
DownloadPackage "readline" &
DownloadPackage "rpcbind" &
wait
DownloadPackage "rpm2tgz" &
DownloadPackage "rp-pppoe" &
DownloadPackage "rsync" &
DownloadPackage "samba" &
DownloadPackage "sdparm" &
DownloadPackage "sed" &
DownloadPackage "sg3_utils" &
DownloadPackage "shadow" &
DownloadPackage "slackpkg" &
DownloadPackage "smartmontools" &
wait
DownloadPackage "sqlite" &
DownloadPackage "sshfs" &
DownloadPackage "sudo" &
DownloadPackage "sysfsutils" &
DownloadPackage "sysklogd" &
DownloadPackage "sysvinit-functions" &
DownloadPackage "sysvinit-scripts" &
DownloadPackage "talloc" &
DownloadPackage "tar" &
DownloadPackage "tcl" &
wait
DownloadPackage "tdb" &
DownloadPackage "telnet" &
DownloadPackage "tevent" &
DownloadPackage "traceroute" &
DownloadPackage "uring" &
DownloadPackage "usb_modeswitch" &
DownloadPackage "usbmuxd" &
DownloadPackage "usbutils" &
DownloadPackage "userspace-rcu" &
DownloadPackage "utempter" &
wait
DownloadPackage "util-linux" &
DownloadPackage "wget" &
DownloadPackage "which" &
DownloadPackage "whois" &
DownloadPackage "wireless_tools" &
DownloadPackage "wpa_supplicant" &
DownloadPackage "xfsdump" &
DownloadPackage "xfsprogs" &
DownloadPackage "xxHash" &
DownloadPackage "xz" &
wait

### only download if not present

[ ! -f /usr/bin/clang ] && DownloadPackage "llvm" &
wait

### packages that require specific stripping

DownloadPackage "aaa_libraries" &
DownloadPackage "binutils" &
DownloadPackage "fftw" & # required by pulse plugins
DownloadPackage "gcc-g++" & # required by aaa_libraries
DownloadPackage "gcc" & # required by aaa_libraries
DownloadPackage "ntp" &
DownloadPackage "openldap" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt
