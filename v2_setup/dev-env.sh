#!/usr/bin/env bash

if [ -z "$XDG_CONFIG_HOME" ]; then
    echo "no xdg config hom"
    echo "using ~/.config"
    XDG_CONFIG_HOME=$HOME/.config
fi

dry="0"

while [[ $# > 0 ]]; do
    if [[ $1 == "--dry" ]]; then
        dry="1"
        export DRY_RUN="1"
    fi
    shift
done

log() {
    if [[ $dry == "1" ]]; then
        echo "[DRY RUN]: $@"
    else
        echo "$@"
    fi
}

execute() {
    log "execute $@"
    if [[ $dry == "1" ]]; then
        return
    fi

    "$@"
}

log "----------------------- dev-env -----------------------"

copy_dir() {
    from=$1
    to=$2

    pushd $from &> /dev/null
    dirs=$(find . -maxdepth 1 -mindepth 1 -type d)
    for dir in $dirs; do
        execute rm -rf $to/$dir
        execute cp -r $dir $to/$dir
    done
    popd $from &> /dev/null
}

copy_file() {
    from=$1
    to=$2

    $name=$(basename $from)

    execute rm $to/$name
    execute cp $from $to/$name
}

copy_dir .config $XDG_CONFIG_HOME
# TODO: add to $PATH, function to add to paths
copy_dir .local $HOME/.local
copy_file .gitconfig $HOME
# TODO: how .tmux.conf is set-up? How to put it into XDG_CONIF_DIR?
copy_file .config/tmux/tmux.conf $HOME/.tmux.conf
