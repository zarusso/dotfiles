### dotfiles

## Installation
```bash
git clone https://github.com/zarusso/dotfiles.git

**Place files in correct locations**
From inside the dotfiles directory run these commands:
```bash
mkdir -p ~/.local/bin
mkdir ~/.config
cp bashrc ~/.bashrc
cp -r startpage wallpapers ~
cp -r config/* ~/.config
cp -r bin/* ~/.local/bin
