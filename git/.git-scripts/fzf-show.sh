#!/bin/bash
# NOTE: whole '.git-scripts' dir is expected to be stored at $HOME
# TODO: all scripts/script-like stuff to be moved into .git-scriots
# TODO: startup script within 'git' directory that creates symbolic links at $HOME
# TODO: overall, need such 'startup'/sync strategy...

# TODO: accept arg and use relative to given ref?
git log --oneline --abbrev=10 | fzf --preview='git show --color=always $(echo {} | cut -d" " -f1)' --preview-window=right:75%