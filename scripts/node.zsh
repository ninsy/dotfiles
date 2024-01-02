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