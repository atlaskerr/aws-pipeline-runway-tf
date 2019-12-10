#!/bin/bash

set -e
set -o pipefail

for i in $(find -name terraform.jsonnet); do
	DIR=$(dirname $i)
	jsonnet $i >$DIR/main.tf.json
done
