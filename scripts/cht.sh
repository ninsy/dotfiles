#!/usr/bin/env bash

# TODO: you can also support cht.sh/terraform/aws/lambda
# TODO: select values like with dazn-cli stuff? dazn-manifest generator?
# TODO: new window can be started with particular env variables

languages=$(echo "golang rust typescript python" | tr " " "\n")
core_utils=$(echo "find xargs sed awk docker git" | tr " " "\n")
selected=$(echo -e "$languages\n$core_utils\nterraform" | fzf)

read -p "Your query: " query

if echo "$languages" | grep $selected > /dev/null 2>&1; then
    tmux split-window -p 45 -h bash -c "curl -q cht.sh/$selected/$(echo "$query" | tr " " "+") | less"
elif echo "$core_utils" | grep $selected > /dev/null 2>&1; then
    tmux split-window -p 45 -h bash -c "curl -q cht.sh/$selected~$query | less"
elif echo "terraform" | grep $selected > /dev/null 2>&1; then
    # TODO: well, actually I can support not only providers, but also individual tf commands, like terraform~destroy
    supported_providers=$(echo "aws azure" | tr " " "\n")
    selected_provider=$(echo -e "$supported_providers" | fzf)
    read -p "Your query: " query

    tmux split-window -p 45 -h bash -c "curl -q cht.sh/terraform/$selected_provider/$query | less"
fi
