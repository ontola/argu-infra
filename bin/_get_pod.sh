#!/bin/sh

kubectl get pod -l "tier=$1,component=$2" -o=jsonpath='{.items[0].metadata.name}'
