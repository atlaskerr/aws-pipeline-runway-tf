#!/bin/bash

set -e
set -o pipefail

for i in $(find -name main.tf.json); do
	DIR=$(dirname $i)
	terraform validate $DIR
done
