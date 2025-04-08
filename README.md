## Downloading The Latest Version

Latest release direct link: https://github.com/porteux/porteux/releases/latest

## About

PorteuX is a Linux distro based on Slackware, inspired by Slax and Porteus and available to the public for free. Its main goal is to be super fast, small, portable, modular and immutable (if the user wants so).

It's already pre-configured for basic usage, including lightweight applications for each one of the 7 desktop environments available. No browser is included, but an app store is provided so you can download the most popular browsers, as well as Steam, VirtualBox, Nvidia drivers, Wine, office suite, multilib (32-bit compat), messengers, emulators, etc.

Out of the box PorteuX can open basically any multimedia file. Hardware acceleration is enabled by default for machines with Intel, AMD or Nvidia cards (for Nvidia cards it's required to download Nvidia driver from the app store).

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

PorteuX is a modular system so it doesn't require a normal setup/installer. You can simply copy the ISO content to your media storage and run from the `boot` folder either `porteux-installer-for-linux.run` or `porteux-installer-for-windows.exe` (depending on which system you're running) to make the unit bootable. It's simple like that. Please avoid ISO installer applications such as Rufus or Etcher because by default they set the bootable unit to be read-only. More details in [/boot/docs/install.txt](https://github.com/porteux/porteux/blob/main/boot/boot/docs/install.txt) file in the ISO.

In order to have PorteuX in a language different than English, download the multilanguage package and use PorteuX Language Switcher application to choose the desired language.

To download a Slackware package that is not present in PorteuX and convert it to .xzm module, run the command `getpkg -m [packageName]` (e.g `getpkg -m gimp`). It's recommended to move the module to porteux/modules folder to ensure it is automatically loaded after boot.

To build anything inside PorteuX, it's recommended to download and activate the 05-devel xzm module, which includes compilers, git, make, headers, etc. To build a driver (e.g. VirtualBox or any physical device), also download and activate 06-crippled_sources xzm module.

To run Windows applications inside PorteuX, in the app store you can find both Wine and Multilib Lite xzm modules. It's recommended to have these 2 modules in /porteux/optional and activate them only when needed.

In order to read Asian characters, please download and activate the module [notoserifcjk-regular.xzm](https://github.com/porteux/porteux/raw/main/extras/notoserifcjk-regular.xzm).

## Default Username and Password

username: guest<br />
password: guest<br />

username: root<br />
password: toor<br />

## Performance

PorteuX is lightweight and snappy. Although it can run on old machines, it is on high end machines that the user will experience everything PorteuX can offer in terms of performance. The ISOs are small and memory RAM consumption is highly optimized.

For better performance, it's recommended to have PorteuX installed on a SSD/NVMe storage unit instead of a USB flash drive, or to select 'Copy To RAM' option in the boot menu. The latter will result in a slower boot time, but after booting the system will run 100% in RAM, which is the fastest way possible.

Boot times are really fast. LXQt, for instance, can boot in only 3 seconds:

[https://youtu.be/DJd38Nch6rQ](https://youtu.be/DJd38Nch6rQ)

Clear Linux, considered the fastest Linux distro, is slower than PorteuX in Geekbench 6:
![clear-linux-40520-vs-porteux-0 9](https://github.com/porteux/porteux/assets/126424580/8ff3cb62-91a0-4171-8c05-133e75845c6b)

Sources:
[ClearLinux40520](https://browser.geekbench.com/v6/cpu/4073056)
[PorteuX0.9](https://browser.geekbench.com/v6/cpu/4087178)

All this performance benefit is achieved without providing ancient software. It means that the kernel, desktop environments and packages are usually as new as possible in the current/rolling release.

## Enable OpenCL support (required by applications like DaVinci Resolve)

In the terminal, run the following commands: <br />
1. `su` (password: toor) <br />
2. `mkdir -p /tmp/opencl-support` <br />
3. `cd /tmp/opencl-support` <br />
4. `getpkg -m libclc llvm mesa ocl-icd spirv-llvm-translator vulkan-sdk` (this may take a while) <br />
5. `activate *.xzm` <br />
6. `mv *.xzm $PORTDIR/modules` <br />
7. `rm -fr /tmp/opencl-support` <br />

## Building

PorteuX can be built in a live session of Slackware 64-bit, Porteus 64-bit or PorteuX 64-bit. At the moment the main scripts are not generating ISOs, but only the xzm files for each module (000-kernel, 001-core, 002-gui, 002-xtra, 003-desktop-environment, etc).

To build PorteuX, run as root the script `createModule.sh` in the exact folder order as described: <br />
1. 000-kernel<br />
2. 001-core<br />
3. 002-gui<br />
4. 002-xtra<br />
5. 003-desktopenvironment (where 'desktopenvironment' is the one of your preference, like 003-lxde)<br />
6. (optional) 05-devel<br />
7. (optional) 08-multilanguage<br />
8. (optional) 0050-multilib-lite<br />

In the end all modules will be in their respective subfolders inside /tmp/porteux-builder-[version].

## Contributing

Feel free to report any issues or request changes. Any constructive feedback is welcome.

## Donate

Please, consider donating to PorteuX project:

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
ponce (@slackware)<br />
tomáš matějíček (@slax)<br />
