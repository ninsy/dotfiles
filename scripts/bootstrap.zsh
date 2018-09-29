#!/usr/bin/env zsh

sudo -v

export DOTFILES=${DOTFILES:="$HOME/.dotfiles"}

cd $DOTFILES/scripts

. ./node.zsh
. ./golang.zsh
. ./rust.zsh
. ./ngrok.zsh
. ./postman.zsh
. ./vscode.zsh
. ./kitty.zsh