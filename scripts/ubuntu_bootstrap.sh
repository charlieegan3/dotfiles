#!/bin/bash

set -x
set -e

export DEBIAN_FRONTEND=noninteractive

# dist upgrade
read -p "Run dist upgrade? y/n" -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  sudo apt-get dist-upgrade
fi

# install gnome
read -p "Install GNOME? y/n" -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  sudo add-apt-repository ppa:gnome3-team/gnome3-staging
  sudo add-apt-repository ppa:gnome3-team/gnome3
  sudo apt update
  sudo apt install gnome gnome-shell
fi

# remove unwanted software
read -p "Remove packages? y/n" -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  unwantedPackages=(aisleriot cheese dconf-editor gnome-calculator gnome-calendar \
    gnome-contacts gnome-documents gnome-games gnome-gettings-started-docs \
    gnome-mahjongg gnome-maps gnome-mines gnome-music gnome-orca gnome-photos \
    gnome-sudoku gnome-user-guide gnome-user-guide gnome-weather gnome-weather \
    libreoffice* rhythmbox* simple-scan totem)

  for package in "${unwantedPackages[@]}"
  do
    sudo apt-get remove -y --purge "$package" || true
  done

  sudo apt-get clean
  sudo apt-get autoremove
fi

read -p "Install packages? y/n" -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'

  wantedPackages=(apt-transport-https direnv ca-certificates \
  curl firefox gconf2 git silversearcher-ag \
  redshift software-properties-common tree vim-gnome)

  sudo apt-get update >> /dev/null
  for package in "${wantedPackages[@]}"
  do
    sudo apt-get install -y "$package"
  done
fi

read -p "Install snaps? y/n" -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  snaps=(chromium heroku go spotify aws-cli)

  for snap in "${snaps[@]}"
  do
    sudo snap install --classic "$snap"
  done
fi

rvmStable="https://raw.githubusercontent.com/wayneeseguin/rvm/stable/binscripts/rvm-installer"
! [[ -e ~/.rvm ]] && \curl -sSL $rvmStable | bash -s stable --ruby --gems=bundler
# clear junk added to bashrc
[[ -e ~/.git ]] && git checkout .bashrc

! [[ -e /usr/bin/node ]] && curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && sudo apt-get install -y nodejs

! [[ -e ~/.tfenv/bin/tfenv ]] && git clone https://github.com/kamatama41/tfenv.git ~/.tfenv \
  && ~/.tfenv/bin/tfenv install latest || true

! [[ -e /usr/local/bin/packer ]] && curl -o /tmp/packer.zip https://releases.hashicorp.com/packer/1.2.1/packer_1.2.1_linux_amd64.zip && \
  unzip /tmp/packer.zip && \
  sudo mv packer /usr/local/bin

if ! [[ -e /snap/bin/docker ]]; then
  sudo snap install docker
  sudo snap connect docker:home
  sudo addgroup --system docker
  sudo adduser $USER docker
  newgrp docker
  sudo snap disable docker
  sudo snap enable docker
fi

if ! [[ -e /usr/local/bin/tmux ]]; then
  sudo apt-get install libncurses5-dev libncursesw5-dev libevent-dev
  curl -L https://github.com/tmux/tmux/releases/download/2.5/tmux-2.5.tar.gz > /tmp/tmux.tar.gz
  sudo apt-get install libevent-dev
  tar xf /tmp/tmux.tar.gz
  cd tmux-2.5
  ./configure && make
  sudo make install
  cd ..
  rm -rf tmux-2.5
fi

# configure dotfiles
if ! [ -e ~/.git ]; then
  git init .
  git remote add -t \* -f origin https://github.com/charlieegan3/dotfiles.git
  git fetch origin
  git reset --hard origin/master
fi

# configure vim
if ! [ -e ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +PlugInstall +qall
  vim +GoInstallBinaries +qall
  go get -u gopkg.in/alecthomas/gometalinter.v2
  gometalinter --install
  curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
fi

# config gnome
gsettings set org.gnome.desktop.background show-desktop-icons true
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.sound event-sounds false
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.wm.preferences auto-raise true
gsettings set org.gnome.desktop.wm.preferences focus-mode click
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Alt>Enter']"
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>Q']"
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver '<Alt>l'
gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot '<Shift><Alt>dollar'
gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot '<Shift><Alt>sterling'
gsettings set org.gnome.desktop.background picture-uri aerial.jpg

if ! [ -e ~/themes/theme-installed ]; then
  bash ~/themes/base16-tube.dark.sh
  touch ~/themes/theme-installed
  echo "Restart terminal to get new profile"
fi
