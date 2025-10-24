#!/bin/zsh

set -e
set -u

# TODO: shellcheck only supports bin/bash...
# TODO: compare with origin/HEAD instead?q
GIT_SCRIPT_DIR="${0:A:h}"
default_branch=$(${GIT_SCRIPT_DIR}/default-branch.sh)
git log "$default_branch"...HEAD --oneline --left-right
