#!/bin/sh

tier=$1
if [ -z "$tier" ]; then
  >&2 echo "Usage: ./bin/service-describe.sh _service_ [component]"
  exit 1
fi

component=$2
component=${component:-'server'}
echo "Describing service '$tier', component '$component'"

pod=$(kubectl get pod -l "tier=$tier,component=$component" -o=jsonpath='{.items[0].metadata.name}')
echo "Selected pod '$pod'"

cmd="kubectl describe pod $pod"
echo "Running '$cmd'"
$cmd
