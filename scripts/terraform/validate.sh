#!/bin/bash

set -e
set -o pipefail

ROOT_DIR=$PWD
FILENAME='main.tf.json'
for i in $(find -name $FILENAME); do
	cd $(dirname $i)
	if [[ ! -d ".terraform" ]]; then
		terraform init
	fi
	terraform validate
	cd $ROOT_DIR
done
