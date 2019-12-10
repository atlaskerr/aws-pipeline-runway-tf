#!/bin/bash

set -e

for i in $(find -name main.tf.json); do
	rm $i
done
