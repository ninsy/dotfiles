#!/usr/bin/env bash

echo "installing neovim..."

# printenv | grep DRY_RUN

git clone https://github.com/neovim/neovim.git --single-branch --branch v0.10.1 $HOME/personal/neovim
cd $HOME/personal/neovim
sudo apt-get install cmake gettext lua5.1 liblua5.1-0-dev
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
