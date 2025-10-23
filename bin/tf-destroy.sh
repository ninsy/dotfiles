#!/bin/bash

usage() {
  echo "Usage: $0 -p <profile> -c <config-dir> [-a <action>]"
  echo "  -c <config-dir>  Specify the directory containing backend config"
  echo "  -a <action>     Specify the action to perform: plan, destroy. Default is destroy."
  echo "  -p <profile>    Which AWS account, passed to dazn aws exec"
  echo " "
  exit 1
}

vault_token() {
  readonly service=${1:?"Vault service must be specified."}
  result=$(dazn vault login -s $1 && vault token lookup | awk '$1 ~ /^id/' | awk '{print $2}')
  echo $result
}

# VAULT_ADDR='https://this.vault.indazn.com'
VAULT_ADDR=https://this.vault.dazn-stage.com

ACTION="plan"
PROFILE="dazn-metrics-dev"

# Read parameters
while getopts ":c:a:p:" opt; do
  case ${opt} in
    c )
      BACKEND_CONFIG=$OPTARG
      ;;
    a )
      ACTION=$OPTARG
      ;;
    p )
      PROFILE=$OPTARG
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      usage
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      usage
      ;;
  esac
done

# Check if directory is provided
if [ -z "$BACKEND_CONFIG" ]; then
  echo "Directory is required."
  usage
fi

res=$(vault_token be-trust)
echo "res is: $res"

# dazn aws exec -p $PROFILE terraform init --backend-config="$BACKEND_CONFIG/config.remote"

# case $ACTION in
#   plan)
#     dazn aws exec -p $PROFILE terraform plan -destroy -out=tfplan -input=false -var-file="$BACKEND_CONFIG/config.tfvars"
#     ;;
#   destroy)
#     dazn aws exec -p $PROFILE terraform apply -destroy
#     ;;
#   *)
#     echo "Unknown action: $ACTION"
#     usage
#     ;;
# esac
