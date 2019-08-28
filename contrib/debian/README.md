
Debian
====================
This directory contains files used to package commad/comma-qt
for Debian-based Linux systems. If you compile commad/comma-qt yourself, there are some useful files here.

## comma: URI support ##


comma-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install comma-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your commaqt binary to `/usr/bin`
and the `../../share/pixmaps/comma128.png` to `/usr/share/pixmaps`

comma-qt.protocol (KDE)

