#!/bin/zsh

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

function select_aws_profile {
    local profile=""
  
    while getopts "p:-:" opt; do
      case $opt in
        p) # For option -p
          profile=$OPTARG
          ;;
        -) # For long options
          case $OPTARG in
            profile)
              profile=$2
              shift
              ;;
            *)
              echo "Unknown option: --$OPTARG"
              return 1
              ;;
          esac
          ;;
        \?) # Invalid option
          echo "Invalid option: -$OPTARG"
          return 1
          ;;
      esac
    done
    shift $((OPTIND - 1))

    if [[ -n $profile ]]; then
      echo "$profile"
      return 0
    fi

    all_profiles=$(aws configure list-profiles)
    dev=$(echo $all_profiles | xargs -0 | grep 'dazn-[^-]*-dev$')
    stage=$(echo $all_profiles | xargs -0 | grep 'dazn-[^-]*-stage$')
    prod=$(echo $all_profiles | xargs -0 | grep 'dazn-[^-]*-prod$')
    all=$(printf "%s\n" "$(echo $dev; echo $stage; echo $prod)")
    aws_profile=$(echo $all | fzf --prompt="Select AWS profile: ")

    if [[ -z "$aws_profile" ]]; then
      echo "No AWS profile selected. Exiting."
      return 1
    fi

    echo $aws_profile
    return 0
}

function s3_get_config() {
  if [[ -z "$FZF_DEFAULT_OPTS" ]]; then
    export FZF_DEFAULT_OPTS='--height=50% --border --inline-info'
  fi

  if ! _exists "aws" || [ ! -f ~/.aws/config ]; then
    echo "requires aws to be installed and configured properly, exiting..."
    return 1
  fi
  
  if ! _exists "fzf"; then
    echo "requires fzf to be installed, exiting..."
    return 1
  fi


  if ! _exists "jless"; then
    echo "requires jless to be installed, exiting..."
    return 1
  fi

  profile=$(select_aws_profile "$@" < "$(tty)")
  if [[ -z "$profile" ]]; then
    echo "No AWS profile selected. Exiting."
    return 1
  fi
  
  config_bucket=$(aws s3 ls --profile $profile | grep config- | fzf --prompt="Select config bucket: " | awk '{print $NF}')
  if [[ -z "$config_bucket" ]]; then
    echo "No config bucket selected. Exiting."
    return 1
  fi

  config_bucket_object_name=$(aws s3 ls --profile $profile "s3://${config_bucket}" --recursive | fzf --prompt="Select nested object: " | awk '{print $NF}')
  if [[ -z "$config_bucket_object_name" ]]; then
    echo "No object selected. Exiting."
    return 1
  fi

  local s3_dump_dir="$HOME/.llamas-vault-config"
  local s3_dump_file="${s3_dump_dir}/${config_bucket_object_name}"

  if [[ ! -d $s3_dump_dir ]]; then
    mktemp -d $s3_dump_dir
  fi

  aws s3 cp --profile $profile "s3://${config_bucket}/${config_bucket_object_name}" $s3_dump_file

  jless $s3_dump_file
}

function sm_get_secret() {
  if [[ -z "$FZF_DEFAULT_OPTS" ]]; then
    export FZF_DEFAULT_OPTS='--height=50% --border --inline-info'
  fi
  
  if ! _exists "aws" || [ ! -f ~/.aws/config ]; then
    echo "requires aws to be installed and configured properly, exiting..."
    return 1
  fi
  
  if ! _exists "fzf"; then
    echo "requires fzf to be installed, exiting..."
    return 1
  fi

  if ! _exists "jq"; then
    echo "requires jq to be installed, exiting..."
    return 1
  fi

  if ! _exists "jless"; then
    echo "requires jless to be installed, exiting..."
    return 1
  fi

  if [[ $# -ne 1 ]]; then
    echo "Usage: sm_get_secret <secret_id>"
    return 1
  fi

  profile=$(select_aws_profile "$@" < "$(tty)")
  if [[ -z "$profile" ]]; then
    echo "No AWS profile selected. Exiting."
    return 1
  fi
  
  local secret_id="$1"

  # TODO: aws profiles - those should be selected from services profile, for example: 'drm-proxy-dev-secrets'
  # TODO: also, allow getting profile from cmdline args...
  # TODO: also, search on secrets from selected 'service' namespace, therefore there should be link between 'service-namespace' and 'service-profile', be-drm-proxy/* with drm-proxy-*-secrets
  aws secretsmanager get-secret-value \
  --profile "$profile" \
  --secret-id "$secret_id" | jq -r '.SecretString' | jless
}

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

function tf_fmt() {
  # TODO: fix it, it still works on .terraform...
  find . -type f \( -name "*.tf" -or -name "*.tfvars" -and ! -path "./.terraform/*" \) -exec terraform fmt {} \;
}

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