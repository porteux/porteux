## Downloading The Latest Version

Latest release direct link: https://github.com/porteux/porteux/releases/latest

## About

PorteuX is a Linux distro based on Slackware, inspired by Slax and Porteus and available to the public for free. Its main goal is to be super fast, small, portable, modular and immutable (if the user wants so).

It's already pre-configured for basic usage, including lightweight applications for each one of the 6 desktop environments available. No browser is included, but an app store is provided so you can download the most popular browsers, as well as Steam, VirtualBox, Nvidia drivers, office suite, multilib, messengers, emulators, etc.

Out of the box PorteuX can open basically any multimedia file. Hardware acceleration is enabled by default for machines with Intel, AMD or Nvidia cards (for Nvidia cards it's required to download Nvidia driver from the app store).

## How To Use

If you're new to PorteuX and have never used Slax or Porteus, it's recommended to read this [in-depth review of Porteus](https://medium.com/@fulalas/porteus-5-review-a-different-and-powerful-linux-distro-33df8789a758).

PorteuX is provided in 2 main versions based on Slackware 64-bit packages: stable (safer) and current/rolling (bleeding edge). After choosing which main version you want, you should choose which desktop environment you want and [download the ISO accordingly](https://github.com/porteux/porteux/releases/latest): <br />
. GNOME<br />
. KDE<br />
. LXDE<br />
. LXQt<br />
. MATE<br />
. Xfce<br />

PorteuX is a modular system so it doesn't require a normal setup/installer. You can simply copy the ISO content to your media storage and run either `porteux-installer-for-linux.run` or `porteux-installer-for-windows.exe` (depending on which system you're running) to make the unit bootable. It's simple like that. Please avoid ISO installer applications such as Rufus or Etcher because by default they set the bootable unit to be read-only. More details in `/boot/docs/install.txt` file in the ISO.

On top of the latest version, old Xfce 4.12 is also provided for the best balance between performance and flexibility. Many patches have been applied to improve the user experience. For optimal performance, remember to turn off the compositor when running 3D applications such as games and benchmarks (Settings -> Window Manager Tweaks -> Compositor tab).

If you want to have PorteuX working on a language different than English, download multilanguage package and use PorteuX Language Switcher application to configure the language.

If you want to build anything inside PorteuX, it's recommended to download and activate the 05-devel xzm module, which includes compilers, git, headers, etc. If you need to build a driver (e.g. VirtualBox or any physical device), you should also download and activate 06-crippled_sources xzm module. It's recommended to have them inside /porteux/optional folder and activate them only when needed.

If you want to run Windows applications inside PorteuX, in the app store you can find both Wine and Multilib Lite xzm modules. Just like 05-devel and 06-crippled_sources, it's recommended to have these 2 modules in /porteux/optional.

To be able to read Asian characters, please download and activate the module [notoserifcjk-regular.xzm](https://github.com/porteux/porteux/raw/main/extras/notoserifcjk-regular.xzm).

## Default Username and Password

username: guest<br />
password: guest<br />

username: root<br />
password: toor<br />

## Performance

PorteuX is lightweight and snappy. Although it can run on old machines, it is on high end machines that the user will experience everything PorteuX can offer in terms of performance. The ISOs have the average size of 425 MB and after boot the whole system takes about 1 GB of RAM, even considering that the system is running in RAM.

Boot times are really fast. LXQt, for instance, can boot in only 3 seconds:

[https://youtu.be/DJd38Nch6rQ](https://youtu.be/DJd38Nch6rQ)

Clear Linux, considered the fastest Linux distro, is slower than PorteuX in Geekbench 6:
![clear-linux-40520-vs-porteux-0 9](https://github.com/porteux/porteux/assets/126424580/8ff3cb62-91a0-4171-8c05-133e75845c6b)

Sources:
[ClearLinux40520](https://browser.geekbench.com/v6/cpu/4073056)
[PorteuX0.9](https://browser.geekbench.com/v6/cpu/4087178)

All this performance benefit is achieved without providing ancient software. It means that the kernel, desktop environments and all applications are usually as new as possible.

## Compatibility with Porteus 5

PorteuX and Porteus follow the same basic structure, so a given module built in Porteus 5 should work in PorteuX current, and modules built in PorteuX stable should work in Porteus 5. However, this does not apply to the base modules (000-kernel, 001-core, 002-gui, 002-xtra and 003-desktopenvironment).

## Building

PorteuX can be built in a live session of Slackware 64-bit, Porteus 64-bit or PorteuX 64-bit. At the moment the main scripts are not generating ISOs, but only the xzm files for each module (000-kernel, 001-core, 002-gui, 002-xtra, 003-desktop-environment, etc).

To build PorteuX, run the commands below as root in the exact order as described: <br />
1. in 000-kernel folder run `createModule.sh`<br />
2. in 001-core folder run `createModule.sh`<br />
3. in 002-gui folder run `createModule.sh`<br />
4. in 002-xtra folder run `createModule.sh`<br />
5. in 003-desktopenvironment folder run `createModule.sh` (where 'desktopenvironment' is the one of your preference)<br />
6. in 05-devel folder run `createModule.sh`<br />
7. (optional) in 08-multilanguage folder run `createModule.sh`<br />
8. (optional) in 0050-multilib-lite folder run `createModule.sh`<br />

In the end all modules will be in their respective subfolders inside /tmp/porteux-builder-[version].

## Contributing

Feel free to report any issues or request changes. Any constructive feedback is welcome.

## Thanks

arleson (core team)<br />
theUtopian (core team)<br />
blaze (@porteus)<br />
brokenman (@porteus)<br />
frank honolka (@snuk)<br />
neko (@porteus)<br />
ncmprhnsbl (@porteus)<br />
patrick volkerding (@slackware)<br />
phantom (@porteus)<br />
ponce (@slackware)<br />
tomáš matějíček (@slax)<br />
