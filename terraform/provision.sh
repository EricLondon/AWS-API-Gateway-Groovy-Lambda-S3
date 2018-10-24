#!/usr/bin/env bash

set -x

: "${AWS_PROFILE:=changeme}"
: "${AWS_REGION:=us-east-1}"
: "${STATE_BUCKET:=changeme}"
: "${STATE_KEY:=eric-test-api-gateway/terraform/base.tfstate}"

action="$1"

TFENV=$(which tfenv)
if [ $? -eq 0 ]; then
  $TFENV install $(cat .terraform-version)
  cat .terraform-version | xargs $TFENV use
fi

rm -f *.tfstate
rm -rf ./.terraform

terraform init \
  -force-copy \
  -backend=true \
  -backend-config "bucket=${STATE_BUCKET}" \
  -backend-config "key=${STATE_KEY}" \
  -backend-config "profile=${AWS_PROFILE}" \
  -backend-config "region=${AWS_REGION}"

terraform plan

if [ "$action" == "apply" ]; then
  terraform apply -auto-approve
fi

if [ "$action" == "destroy" ]; then
  terraform destroy
fi
