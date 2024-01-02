# TODO: reuse _exists...
_exists() {
  command -v $1 >/dev/null 2>&1
}

function setup_npm {
  if ! _exists "npm"; then
    echo "requires npm to be installed, exiting..."
    return 1
  fi

  unset NPM_TOKEN
  unset NODE_AUTH_TOKEN

  rm $HOME/.npmrc

  npm login --registry https://npm.daznplatform.com/

  token_val=$(grep "//npm.daznplatform.com/:_authToken=" ~/.npmrc | awk -F "=" '{print $2}')

  npm config set @dazn:registry https://npm.daznplatform.com/

  export NODE_AUTH_TOKEN=$(echo $token_val)
  export NPM_TOKEN=$(echo $token_val)
}

# TODO: to be used from within ~/.zshrc
function setup_n {
 if [ ! -d /usr/local/n ]; then
    # make cache folder (if missing) and take ownership
    sudo mkdir -p /usr/local/n
    sudo chown -R $(whoami) /usr/local/n
    # make sure the required folders exist (safe to execute even if they already exist)
    sudo mkdir -p /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
    # take ownership of Node.js install destination folders
    sudo chown -R $(whoami) /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
  fi 
}