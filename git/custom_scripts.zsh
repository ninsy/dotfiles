#!/bin/zsh

function commit_from_month() {
    # assumes it runs on BSD
    # TODO: set custom month as reference
    curr_month_first=$(date -v1d +%d-%m-%Y)
    curr_month_last=$(date -v1d -v+1m -v-1d +%d-%m-%Y)
    git log --after=$curr_month_first --until=$curr_month_last --author=$(git config user.email) --pretty=format:"[%h]%ad : %s"
}
