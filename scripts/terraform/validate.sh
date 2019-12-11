#!/bin/bash

set -e
set -o pipefail

ROOT_DIR=$PWD
FILENAME='main.tf.json'
for i in $(find -name $FILENAME); do
	DIR=$(dirname $i)
	cd $DIR
	if [[ ! -d ".terraform" ]]; then
		terraform init
	fi
	echo $DIR
	terraform validate
	cd $ROOT_DIR
done
