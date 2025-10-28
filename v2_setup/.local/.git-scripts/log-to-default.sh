#!/bin/zsh

set -e
set -u

# TODO: shellcheck only supports bin/bash...
# TODO: compare with origin/HEAD instead?
GIT_SCRIPT_DIR="${0:A:h}"

curr_branch=$(git rev-parse --abbrev-ref HEAD)
default_branch=$(${GIT_SCRIPT_DIR}/default-branch.sh)

set +e
git stash -u
set -e


git co "$default_branch"
git pull
git co "$curr_branch"

set +e
git stash pop
set -e

git log "$default_branch"...HEAD --oneline --left-right
