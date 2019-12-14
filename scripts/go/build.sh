#!/bin/bash

set -e
set -o pipefail

for i in $(find $PWD/iac -name main.go); do
	DIR=$(dirname $i)
	go build -o $DIR/main $DIR
	zip -j $DIR/main.zip $DIR/main
done
