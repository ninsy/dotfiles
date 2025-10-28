#!/bin/zsh

# TODO: to be handled by runs?
# TODO: scripts into .local/scripts, Brewfile into .config/brew ?

_exists() {
  command -v $1 >/dev/null 2>&1
}

if ! _exists "brew"; then
    echo "homebrew not found, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # TODO: ?
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew update

brew tap homebrew/bundle
brew bundle --file ./Brewfile

# TODO: test it on some docker container... actually include Dockerfile that sets up latest osx image and run to verify.