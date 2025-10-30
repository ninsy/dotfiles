#!/bin/zsh

set -e
set -u

# TODO: shellcheck only supports bin/bash...
GIT_SCRIPT_DIR="${0:A:h}"

curr_branch=$(git rev-parse --abbrev-ref HEAD)
default_branch=$(${GIT_SCRIPT_DIR}/default-branch.sh)

# TODO: stash only if there are some changes to existing/there are new files
git stash -u
git pull origin "$curr_branch"
git co "$default_branch"
git pull
git co "$curr_branch"
git rebase "$default_branch"
# TODO: only apply if was stashed before
git stash pop
