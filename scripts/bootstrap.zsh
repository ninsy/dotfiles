#!/usr/bin/env zsh

sudo -v

export DOTFILES=${DOTFILES:="$HOME/.dotfiles"}

cd $DOTFILES/scripts

source ./aws.zsh
source ./node.zsh
source ./golang.zsh
source ./rust.zsh
source ./ngrok.zsh
source ./vscode.zsh
source ./terraform.zsh
source ./utils.zsh
source ./vscode.zsh