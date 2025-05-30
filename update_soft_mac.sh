#!/bin/bash

dot_dir="${HOME}/.dotfiles"

echo -e "Updating macOS"
sudo softwareupdate -i -a

echo -e "Updating brew"
brew update >/dev/null 2>&1

echo -e "\tUpgrading brew installs"
brew upgrade

echo -e "\tUpgrading brew cask installs"
brew upgrade --cask
