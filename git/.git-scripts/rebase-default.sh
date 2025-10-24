#!/bin/zsh

set -e
set -u

# TODO: shellcheck only supports bin/bash...
GIT_SCRIPT_DIR="${0:A:h}"

curr_branch=$(git rev-parse --abbrev-ref HEAD)
git stash -u
default_branch=$(${GIT_SCRIPT_DIR}/default-branch.sh)
git co "$default_branch"
git pull
git co "$curr_branch"
git rebase "$default_branch"
git stash pop
