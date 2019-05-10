
Debian
====================
This directory contains files used to package commacoind/commacoin-qt
for Debian-based Linux systems. If you compile commacoind/commacoin-qt yourself, there are some useful files here.

## commacoin: URI support ##


commacoin-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install commacoin-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your commacoinqt binary to `/usr/bin`
and the `../../share/pixmaps/commacoin128.png` to `/usr/share/pixmaps`

commacoin-qt.protocol (KDE)

