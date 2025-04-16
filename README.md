### dotfiles

## Installation
```bash
sudo pacman -S git
git clone https://github.com/zarusso/dotfiles.git
```
To go through these steps you'll need an AUR helper, here are the steps to download paru:
```bash
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```
Feel free to remove the paru folder just downloaded

## Place files in correct locations
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
Check if lightdm is working correctly:
```bash
lightdm --test-mode --debug
```
If it's working fine, enable the service:
```bash
sudo systemctl enable lightdm
```

