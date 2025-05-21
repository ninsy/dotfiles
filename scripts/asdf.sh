#!/bin/bash

# TODO: replace with mise-en-place...
JAVA_VER="openjdk-23"
NODE_VER="lts"

# TODO mac specific
brew install coreutils curl git

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0

# TODO mac/zsh specific
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc

echo "Installing nodejs plugin"
# TODO mac specific dependency install
brew install gpg gawk
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install java $NODE_VER
asdf global nodejs $NODE_VER

echo "Installing java plugin"
# TODO: mac specific install and deps (linux requires sha256sum)
brew install curl jq unzip
asdf plugin-add java https://github.com/halcyon/asdf-java.git
# TODO: zsh specific
echo -e "\n. ~/.asdf/plugins/java/set-java-home.zsh" >> ${ZDOTDIR:-~}/.zshrc
asdf install java $JAVA_VER
asdf global java $JAVA_VER

echo "Installing golang plugin"
# TODO: mac specific
brew install coreutils curl
asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
echo -e "\n. ~/.asdf/plugins/golang/set-env.zsh" >> ${ZDOTDIR:-~}/.zshrc

# TODO: python, how does virtualenv/python dep installation works?