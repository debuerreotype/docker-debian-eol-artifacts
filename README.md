# Debian EOL

This repository contains tags for [Debian releases](https://www.debian.org/releases/) which are [now End of Life](https://wiki.debian.org/DebianReleases#Production_Releases), and thus are available from [archive.debian.org](http://archive.debian.org).

Blurbs about each release listed below are from [the `debian-history` package](https://packages.debian.org/sid/debian-history), whose content [is also available online](https://www.debian.org/doc/manuals/project-history/releases.en.html).

Image contents are generated reproducibly via [the `debuerreotype` tool](https://github.com/debuerreotype/debuerreotype) (also used for [the `debian` official image](https://hub.docker.com/_/debian)), and the exact scripts and rootfs tarballs can be found in [github.com/debuerreotype/docker-debian-eol-artifacts](https://github.com/debuerreotype/docker-debian-eol-artifacts) (see especially the `dist-*` branches, such as [`dist-potato`'s `potato` directory](https://github.com/debuerreotype/docker-debian-eol-artifacts/tree/dist-potato/potato)).

Issues? https://github.com/debuerreotype/docker-debian-eol-artifacts/issues

## `debian/eol:stretch`

> Debian 9 *Stretch* (June 2017): named for the toy rubber octopus with suckers on her eight long arms that appeared in Toy Story 3.
>
> The release was frozen on February 7th, 2017.
>
> Support for the powerpc architecture was dropped in this release, whileas the mips64el architecture was introduced.  This release introduced debug packages with a new repository in the archive, packages from this repository provided debug symbols automatically for packages.

## `debian/eol:jessie`

> Debian 8 *Jessie* (April 2015): named for the cow girl doll who first appeared in Toy Story 2.
>
> This release introduced for the first time the systemd init system as default. Two new architectures were introduced: arm64 and ppc64el and three architectures were dropped: s390 (replaced by s390x), ia64 and sparc.  The Sparc architecture had been present in Debian for 16 years, but lacked developer support to make it maintainable in the distribution.
>
> The release included many security improvements such as a new kernel that nullified a whole set of security vulnerabilities (symlink attacks), a new way to detect packages which were under security support, more packages built with hardened compiler flags and a new mechanism (needrestart) to detect sub-systems which had to be restarted in order to propagate security updates after an upgrade.

## `debian/eol:wheezy`

> Debian 7.0 *Wheezy* (May 2013): named for the rubber toy penguin with a red bow tie.
>
> The release was frozen on June 30, 2012, very close to the Debian developers gathering in the 12th DebConf at Managua, Nicaragua.
>
> One architecture was included in this release (armhf) and this release introduced multi-arch support, which allowed users to install packages from multiple architectures on the same machine.  Improvements in the installation process allowed visually impaired people to install the system using software speech for the first time.
>
> This was also the first release that supported the installation and booting in devices using UEFI firmware.

## `debian/eol:squeeze`

> Debian 6.0 *Squeeze* (February 2011): named for the green three-eyed aliens.
>
> The release was frozen on August 6, 2010, with many of the Debian developers gathered at the 10th DebConf at New York City.
>
> While two architectures (alpha and hppa) were dropped, two architectures of the new [FreeBSD port](http://www.debian.org/ports/kfreebsd-gnu/) (kfreebsd-i386 and kfreebsd-amd64) were made available as *technology preview*, including the kernel and userland tools as well as common server software (though not advanced desktop features yet).  This was the first time a Linux distribution has been extended to also allow use of a non-Linux kernel.
>
> The new release introduced a dependency based boot sequence, which allowed for parallel init script processing, speeding system startup.

## `debian/eol:lenny`

> Debian 5.0 *Lenny* (February 2009): named for the wind up binoculars in the *Toy Story* movies.  One architecture was added in this release: [ARM EABI](https://wiki.debian.org/ArmEabiPort) (or *armel*), providing support for newer ARM processors and deprecating the old ARM port (*arm*).  The [m68k](https://wiki.debian.org/M68k) port was not included in this release, although it was still provided in the *unstable* distribution.  This release did not feature the [FreeBSD port](http://www.debian.org/ports/kfreebsd-gnu/), although much work on the port had been done to make it qualify it did not meet yet the [qualification requirements](https://release.debian.org/lenny/arch_qualify.html) for this release.
>
> Support of small factor devices in this release was increased by the added support for Marvell's Orion platform which was used in many storage devices and also provided supported several Netbooks.  Some new build tools were added which allowed Debian packages to be cross-built and shrunk for embedded ARM systems.  Also, netbooks of varied vendors were now supported and the distribution provided software more suitable for computers with relatively low performance.
>
> It was also the first release to provide free versions of Sun's Java technology, making it possible to provide Java applications in the *main* section.

## `debian/eol:etch`

> Debian 4.0 *Etch* (8 April 2007): named for the sketch toy in the movie.  One architecture was added in this release: [AMD64](http://www.debian.org/ports/amd64/), and official support for [m68k](http://www.debian.org/ports/m68k/) was dropped. This release continued using the *debian-installer*, but featuring in this release a graphical installer, cryptographic verification of downloaded packages, more flexible partitioning (with support for encrypted partitions), simplified mail configuration, a more flexible desktop selection, simplified but improved localization and new modes, including a *rescue* mode.  New installations would not need to reboot through the installation process as the previous two phases of installation were now integrated.  This new installer provided support for scripts using composed characters and complex languages in its graphical version, increasing the number of available translations to over fifty.  Sam Hocevar was appointed Project Leader the very same day, and the project included more than one thousand and thirty Debian developers.  The release contained around 18,000 binary packages over 20 binary CDs (3 DVDs) in the official set.  There were also two binary CDs available to install the system with alternate desktop environments different to the default one.

## `debian/eol:sarge`

> Debian 3.1 *Sarge* (6 June 2005): named for the sergeant of the Green Plastic Army Men.  No new architectures were added to the release, although an unofficial AMD64 port was published at the same time and distributed through the new Alioth project hosting site.  This release features a new installer: *debian-installer*, a modular piece of software that feature automatic hardware detection, unattended installation features and was released fully translated to over thirty languages.  It was also the first release to include a full office suite: OpenOffice.org.  Branden Robinson had just been appointed as Project Leader.  This release was made by more than nine hundred Debian developers, and contained around 15,400 binary packages and 14 binary CDs in the official set.

## `debian/eol:woody`

> Debian 3.0 *Woody* (19 July 2002): Named for the main character the *Toy Story* movies: "Woody" the cowboy.  Even more architectures were added in this release: [IA-64](http://www.debian.org/ports/ia64/), [HP PA-RISC](http://www.debian.org/ports/hppa/), [MIPS (big endian)](http://www.debian.org/ports/mips/), [MIPS (little endian)](http://www.debian.org/ports/mipsel/) and [S/390](http://www.debian.org/ports/s390/).  This is also the first release to include cryptographic software due to the restrictions for exportation being *lightened* in the US, and also the first one to include KDE, now that the license issues with QT were resolved.  With Bdale Garbee recently appointed Project Leader, and more than 900 Debian developers, this release contained around 8,500 binary packages and 7 binary CDs in the official set.

## `debian/eol:potato`

> Debian 2.2 *Potato* (15 August 2000): Named for "Mr Potato Head" in the *Toy Story* movies.  This release added support for the [PowerPC](http://www.debian.org/ports/powerpc/) and [ARM](http://www.debian.org/ports/arm/) architectures.  With Wichert still serving as Project Leader, this release consisted of more than 3900 binary packages derived from over 2600 source packages maintained by more than 450 Debian developers.
