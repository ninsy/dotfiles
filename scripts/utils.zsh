#!/bin/zsh


function loadenv() {
  # TODO: save pwd in some file, so that when you call unset_all in works in lifo manner
  if [ ! -f .env ]; then
    echo "No .env file in directory $(pwd), exiting..."
    return
  fi
  export $(grep -v '^#' .env | xargs)
}
alias le="loadenv"

function unset_all() {
  if [ ! -f .env ]; then
    echo "No .env file in directory $(pwd), exiting..."
    return
  fi
  unset $(grep -v '^#' .env | cut -d "=" -f1)
}
alias ua="unset_all"

function git_prune() {
  for n in `find $1 -name .git`
  do
    cd ${n/%.git/}
    git prune -v
  done
}

commit_hash() {
  git rev-parse --short=10 HEAD
}

default_branch() {
  git remote show origin | sed -n '/HEAD branch/s/.*: //p'
}

pull_default() {
  git pull origin $(default_branch)
}
alias pd='pull_default'

vault_token() {
  readonly service=${1:?"Vault service must be specified."}
  dazn vault login -s $1 && vault token lookup | awk '$1 ~ /^id/' | awk '{print $2}'
}
