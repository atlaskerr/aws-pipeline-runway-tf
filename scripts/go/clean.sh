#!/bin/bash

set -e

for i in $(find -name main.go); do
	DIR=$(dirname $i)
	rm -rf $DIR/main $DIR/main.zip
done
