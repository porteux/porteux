## About

PorteuX is a Linux distro based on Slackware, inspired by Slax and Porteus and available to the public for free. Its main goal is to be super fast, small, portable, modular and immutable (if the user wants so).

It's already pre-configured for basic usage, including lightweight applications for each one of the 6 desktop environments available. No browser is included, but an app store is provided so you can download the most popular browsers, as well as Steam, VirtualBox, Nvidia drivers, office suite, multilib lite, messengers, emulators, etc.

Out of the box PorteuX can open basically any multimedia file. Hardware acceleration will be activated by default for machines with Intel, AMD or Nvidia cards (external Nvidia driver required and available on the app store).

## How To Use

If you're new to PorteuX and have never used Porteus or Slax, it's recommended to read this [in-depth review of Porteus](https://medium.com/@fulalas/porteus-5-review-a-different-and-powerful-linux-distro-33df8789a758).

PorteuX is provided in 2 main versions based on Slackware 64-bit packages: stable and current/unstable. Current/unstable is the bleeding edge one and it's recommended for testing. After choosing which main version you want, you should choose which desktop environment you want and [download the ISO accordingly](https://github.com/porteux/porteux/releases): <br />
. GNOME 42.9<br />
. KDE 5.23.5 (or 5.27.3 in current)<br />
. LXDE 0.10.1<br />
. LXQt 1.2.0<br />
. MATE 1.27<br />
. Xfce 4.12<br />
. Xfce 4.16<br />
. Xfce 4.18<br />

PorteuX is a modular system so it doesn't require a normal setup/installer. You can simply copy the ISO content to your media storage and run either `porteux-installer-for-linux.run` or `porteux-installer-for-windows.exe` (depending on which system you're running) to make the unit bootable. It's simple like that. For more details, please read `install.txt` file in the root folder of the ISO.

Xfce 4.12 is the recommended version for the best balance between performance and flexibility. Many patches have been applied to this Xfce version to improve the user experience.

If you want to build anything inside PorteuX, it's recommended to download and activate the 05-devel xzm module, which includes compilers, git, headers, etc. If you need to build a driver (e.g. VirtualBox or any physical device), you should also download and activate 06-crippled_sources xzm module. It's not recommended to have these 2 modules activated during boot time, instead put them inside /porteux/optional folder and activate them only when needed.

If you want to run Windows applications inside PorteuX, in the app store you can find both Wine and Multilib Lite xzm modules. Just like 05-devel and 06-crippled_sources, it's not recommended to have these 2 modules activated during boot time.

To be able to read Asian characters, please download and activate the module [notoserifcjk-regular.xzm](https://github.com/porteux/porteux/raw/main/extras/notoserifcjk-regular.xzm).

## Default Username and Password

username: guest<br />
password: guest<br />

username: root<br />
password: toor<br />

## Performance

PorteuX is lightweight and snappy. Although it can run on old machines, it is on high end machines that the user will experience everything PorteuX can offer in terms of performance. Its ISOs have the average size of 410 MB and after boot the whole system takes no more than 1 GB of RAM, even considering that everything is loaded in RAM.

Boot times are really fast. LXQt, for instance, can boot in only 3 seconds:

[https://youtu.be/DJd38Nch6rQ](https://youtu.be/DJd38Nch6rQ)

Clear Linux, considered the fastest Linux distro, is slower than PorteuX:
![clearlinux-vs-porteux](https://user-images.githubusercontent.com/126424580/230231475-8f2f3f68-8ac1-4338-924c-5aa7c147bd8c.png)

All this performance benefit is achieved without providing ancient software. It means that the kernel, desktop environments and all applications are usually as new as possible.

## Compatibility with Porteus 5

Apart from 001-core, 002-xorg and 002-xtra modules, all Porteus 5 modules are compatible with PorteuX. In order to use a given Porteus 5 desktop environment (003-xx) you need to download and activate (during boot time) the compatibility module [009-porteus5-compatibility-stable.xzm](https://github.com/porteux/porteux/raw/main/extras/009-porteus5-compatibility-stable.xzm) (or [009-porteus5-compatibility-current.xzm](https://github.com/porteux/porteux/raw/main/extras/009-porteus5-compatibility-current.xzm) if you're using PorteuX current/unstable)

## Building

PorteuX can be built in a live session of Slackware 64-bit, Porteus 64-bit or PorteuX 64-bit. At the moment the main scripts are not generating ISOs, but only the xzm files for each module (000-kernel, 001-core, 002-xorg, 002-xtra, 003-desktop-environment, 05-devel, 06-crippled_sources).

To build PorteuX, run the commands below in the exact order as described: <br />
1- in 000-kernel folder call `createModule.sh`<br />
2- in 001-core folder call `createModule.sh`<br />
3- in 002-xorg folder call `createModule.sh`<br />
4- in 002-xtra folder call `createModule.sh`<br />
5- in 003-desktopenvironment folder call `createModule.sh` (where 'desktopenvironment' is the one of your preference)<br />
6- in 05-devel folder call `createModule.sh`<br />

In the end all modules will be in their respective subfolders inside /tmp/porteux-builder-[version].

It's recommended to have at least 8 GB of RAM (if building GNOME, 16 GB is required).

## Contributing

Feel free to report any issues or request changes. Any feedback is welcome.

## Thanks

arleson (core team)<br />
blaze (@porteus)<br />
brokenman (@porteus)<br />
frank honolka (@snuk)<br />
ncmprhnsbl (@porteus)<br />
patrick volkerding (@slackware)<br />
phantom (@porteus)<br />
ponce (@slackware)<br />
tomáš matějíček (@slax)<br />
