#!/bin/bash

set -e

ROOT_DIR=$(pwd)


destroy_layer () {

  LAYER=$1

  echo ""
  echo "Destroy ${LAYER}"

  cd "${ROOT_DIR}/${LAYER}"

  terraform destroy -auto-approve
}


destroy_layer "03-platform"

destroy_layer "02-eks"

destroy_layer "01-network"