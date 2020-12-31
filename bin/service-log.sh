#!/bin/bash

tier=$1
if [ -z "$tier" ]; then
  >&2 echo "Usage: ./bin/service-log.sh _service_ [component] [kubectl logs flags]"
  exit 1
fi

component=$2
reqsubstr=-
rest_index=2

if [ -z "${component##*$reqsubstr*}" ]; then
  component='server'
  rest_index=1
fi
rest_args="${@:2}"

component=${component:-'server'}
echo "Showing logs for service '$tier', component '$component'"

pod=$("$(dirname "$0")/_get_pod.sh" "$tier" "$component")
echo "Selected pod '$pod'"

cmd="kubectl logs $rest_args $pod"
echo "running '$cmd'"
$cmd
