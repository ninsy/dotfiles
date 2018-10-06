_exists() {
  command -v $1 > /dev/null 2>&1
}

if _exists trash; then
  alias rm='trash'
else
  alias rm='rm -i'
fi

alias clr='clear'
alias ls="ls -alht --color=always"
alias ls-dir="ls -alht --color=always | grep ^d"
alias df="df -h"
alias mkdir="mkdir -pv"

alias js-clean="find ~/Documents/Coding/js -name 'node_modules' -exec trash '{}' +"
alias js="cd ~/Documents/Coding/js && code ."
alias rs="cd ~/Documents/Coding/rust && code ."
alias py="cd ~/Documents/Coding/python && code ."

alias etcher="etcher-electron"
alias post="nohup Postman >/dev/null 2>&1 & disown"