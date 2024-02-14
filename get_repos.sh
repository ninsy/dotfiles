#!/bin/bash

REPO_LIST='~/.repos.txt'
REPO_PATH='~/Documents/repos'

function backup() {
    cd $REPO_PATH
    find . -type d -name ".git" -exec sh -c 'cd "$(dirname {})" && echo "$(git config --get remote.origin.url)"' \; >> $REPO_LIST
    # TODO: rclone, push to dotfiles repo?...
}

function install() {
    cd $REPO_PATH
    xargs -0 -n 1 git clone < <(tr \\n \\0 <\$REPO_LIST)
}
