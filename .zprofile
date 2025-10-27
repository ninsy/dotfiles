# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
export ZSH_THEME="robbyrussell"

export EDITOR='nvim'
export PAGER=less

# TODO: get rid of - separate files, add to PATH instead?
export SCRIPTS_FILE=$HOME/.local/bin/zsh-scripts.sh

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagacedw

export ZPLUG_HOME=/usr/local/opt/zplug

export LC_ALL=en_US.UTF-8

# ~~<TAB>
export FZF_COMPLETION_TRIGGER='~~'
export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# TODO: use copy_file?
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/.ripgreprc"

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=10000000
export HIST_STAMPS="yyyy-mm-dd"
export HISTORY_IGNORE="(ls|cd|pwd|exit|cd)*"

export PATH="$HOME":$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"
export PATH=/usr/local/bin:$PATH
# TODO: get rid of?
export PATH=$SCRIPTS_FILE:$PATH

bindkey -s ^f "tmux-sessionizer\n"
bindkey "^b" beginning-of-line

# TODO: fix!
bindkey "^[f" forward-word
bindkey "^[b" backward-word

# TODO: what about stuff based on .env.exampe? there is stuff that's required to work for various scripts