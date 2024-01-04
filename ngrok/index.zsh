#!/bin/zsh

# TODO: it has to be run from .zshrc...
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi