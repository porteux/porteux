## Downloading The Latest Version

Latest release direct link: https://github.com/porteux/porteux/releases/latest

## About

PorteuX is a Linux distro based on Slackware, inspired by Slax and Porteus and available to the public for free. Its main goal is to be super fast, small, portable, modular and immutable (if the user wants so).

It's already pre-configured for basic usage, including lightweight applications for each of the 7 desktop environments available. No browser is included, but an app store is provided so you can download the most popular browsers, as well as Steam, VirtualBox, Nvidia drivers, Wine, office suite, multilib (32-bit compatibility), messengers, emulators, etc.

Out of the box, PorteuX can open basically any multimedia file. Hardware acceleration is enabled by default for machines with Intel, AMD or Nvidia cards (for Nvidia cards it's required to download the Nvidia driver from the app store).

## How To Use

If you're new to PorteuX and have never used Slax or Porteus, it's recommended to read this [in-depth review of Porteus](https://medium.com/@fulalas/porteus-5-review-a-different-and-powerful-linux-distro-33df8789a758).

PorteuX is provided in 2 main versions based on Slackware 64-bit packages: stable (safer) and current/rolling (bleeding edge). After choosing which main version you want, you should choose which desktop environment you want and [download the ISO accordingly](https://github.com/porteux/porteux/releases/latest): <br />
. Cinnamon<br />
. GNOME<br />
. KDE<br />
. LXDE<br />
. LXQt<br />
. MATE<br />
. Xfce<br />

PorteuX is a modular system so it doesn't require a normal setup/installer. You can simply copy the ISO content to your media storage and run from the `boot` folder either `porteux-installer-for-linux.run` or `porteux-installer-for-windows.exe` (depending on which system you're running) to make the unit bootable. It's that simple. Please avoid ISO installer applications like Rufus or Etcher because by default they set the bootable unit to be read-only. More details can be found in the [/boot/docs/install.txt](https://github.com/porteux/porteux/blob/main/boot/boot/docs/install.txt) file in the ISO.

To use PorteuX in a language other than English, download the multilanguage package and use the PorteuX Language Switcher application to choose the desired language.

To download a Slackware package that is not present in PorteuX and convert it to a .xzm module, run the command `getpkg -m [packageName]` (e.g `getpkg -m gimp`). It's recommended to move the module to the `porteux/modules` folder to ensure it is automatically loaded after boot.

To build anything inside PorteuX, it's recommended to download and activate the `05-devel` xzm module, which includes compilers, git, make, headers, etc. To build a driver (e.g. VirtualBox or any physical device), also download and activate the `06-crippled-sources` xzm module.

To run Windows applications inside PorteuX, you can find both Wine and Multilib Lite xzm modules in the app store. It's recommended to have these 2 modules in `/porteux/optional` and activate them only when needed.

To read Asian characters, download and activate the [notoserifcjk-regular.xzm](https://github.com/porteux/porteux/raw/main/common/notoserifcjk-regular.xzm) module. Some PDFs may also require `poppler-data` package, also available via `getpkg` command.

## Default Username and Password

username: guest<br />
password: guest<br />

username: root<br />
password: toor<br />

## Performance

PorteuX is lightweight and snappy. Although it can run on old machines (as long as they support SSE4.2), it is on high-end machines that the user will experience everything PorteuX can offer in terms of performance. The ISOs are small, and memory RAM consumption is highly optimized.

For better performance, it's recommended to have PorteuX installed on a SSD/NVMe storage unit instead of a USB flash drive, or to select the 'Copy To RAM' option in the boot menu. The latter will result in a slower boot time, but after booting the system will run 100% in RAM, which is the fastest way possible.

Boot times are really fast. LXQt, for instance, can boot in only 3 seconds:

[https://youtu.be/DJd38Nch6rQ](https://youtu.be/DJd38Nch6rQ)

Clear Linux, considered the fastest Linux distro, is slower than PorteuX in Geekbench 6:
![clear-linux-40520-vs-porteux-0 9](https://github.com/porteux/porteux/assets/126424580/8ff3cb62-91a0-4171-8c05-133e75845c6b)

Sources:
[ClearLinux40520](https://browser.geekbench.com/v6/cpu/4073056)
[PorteuX0.9](https://browser.geekbench.com/v6/cpu/4087178)

All this performance benefit is achieved without providing ancient software. This means that the kernel, desktop environments and packages are usually as new as possible in the current/rolling release.

## Enable OpenCL support (required by applications like DaVinci Resolve)

In the terminal, run the following commands: <br />
1. `su` (password: toor) <br />
2. `cd $PORTDIR/modules` <br />
3. `getpkg -m libclc llvm mesa ocl-icd spirv-llvm-translator vulkan-sdk`<br />
4. `activate -q libclc*.xzm llvm*.xzm mesa*.xzm ocl-icd*.xzm spirv-llvm-translator*.xzm vulkan-sdk*.xzm` <br />

This only needs to be done once, as these modules will be activated automatically every time the machine boots.

## Building

PorteuX can be built in a live session of Slackware 64-bit or PorteuX 64-bit. At the moment, the main scripts do not generate ISOs, but only the xzm files for each module (000-kernel, 001-core, 002-gui, 002-xtra, 003-desktop-environment, etc).

To build PorteuX, run the `createModule.sh` script as root, in the exact folder order as described: <br />
1. 000-kernel<br />
2. 001-core<br />
3. 002-gui<br />
4. 002-xtra<br />
5. 003-desktopenvironment (where 'desktopenvironment' is your preferred environment, like 003-lxde)<br />
6. (optional) 05-devel<br />
7. (optional) 08-multilanguage<br />
8. (optional) 0050-multilib-lite<br />

At the end, all modules will be in their respective subfolders inside /tmp/porteux-builder-[version].

## Contributing

Feel free to report any issues or request changes. Any constructive feedback is welcome.

## Donate

Please consider donating to the PorteuX project:

https://paypal.me/porteux<br />
https://buymeacoffee.com/porteux<br />

## Thanks

arleson (core team)<br />
theUtopian (core team)<br />
blaze (@porteus)<br />
brokenman (@porteus)<br />
frank honolka (@snuk)<br />
luckyCyborg (@slackware)<br />
ncmprhnsbl (@porteus)<br />
neko (@porteus)<br />
patrick volkerding (@slackware)<br />
phantom (@porteus)<br />
tomáš matějíček (@slax)<br />
