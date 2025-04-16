# dotfiles

## Dependencies
To go through these steps you'll need an AUR helper, here are the steps to download paru:
```bash
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```
Feel free to remove the paru folder just downloaded

Required fonts:
```bash
paru -S adobe-source-code-pro-fonts ttf-font-awesome ttf-jetbrains-mono-nerd ttf-ubuntu-font-family
```
Packages required to make the system work correctly:
```bash
paru -S alacritty arcolinux-logout betterlockscreen dunst firefox htop libnotify maim nitrogen oh-my-posh picom pulseaudio qalculate-gtk rofi volnoti
```

## Installation
```bash
sudo pacman -S git
git clone https://github.com/zarusso/dotfiles.git
```

## Place files in the correct locations
From inside the dotfiles directory run these commands:
```bash
mkdir -p ~/.local/bin
mkdir ~/.config

cp bashrc ~/.bashrc
cp -r startpage wallpapers ~
cp -r config/* ~/.config
cp -r bin/* ~/.local/bin
```
**Make sure to add '/home/YOUR_USER/.local/bin' to your path editing /etc/profile**

## XMonad Installation
Install dependencies (arch linux):
```bash
paru -S xorg-server xorg-apps xorg-xinit xorg-xmessage libx11 libxft libxinerama libxrandr libxss pkgconf cairo pango stack
```
Prepare to build:
```bash
cd ~/.config/xmonad
git clone https://github.com/xmonad/xmonad
git clone https://github.com/xmonad/xmonad-contrib
git clone https://codeberg.org/xmobar/xmobar
```
Build using stack:
```bash
stack upgrade
stack init
stack install
```
If everything went correctly you should be able to run:
```bash
xmonad --version
```

## Setup LightDM
Installation:
```bash
paru -S lightdm lightdm-mini-greeter
```
Edit the /etc/lightdm/lightdm.conf and set the greeter-session:
```bash
[Seat:*]
greeter-session=lightdm-mini-greeter
```
And set the correct user in /etc/lightdm/lightdm.conf:
```bash
user = YOUR_USERNAME
```
Create the file /usr/share/xsessions/xmonad.desktop for the XMonad desktop entry and write:
```bash
[Desktop Entry]
Encoding=UTF-8
Name=xmonad
Comment=Start xmonad
Exec=/home/YOUR_USERNAME/.local/bin/xmonad
Type=Application
```
And specify in ~/.dmrc the session you want to execute:
```bash
[Desktop]
Session=xmonad
```
Check if lightdm is working correctly:
```bash
lightdm --test-mode --debug
```
If it's working fine, enable the service:
```bash
sudo systemctl enable lightdm
```
And restart the PC.

In case of problems at boot you should be able to enter the system using Alt+F2
