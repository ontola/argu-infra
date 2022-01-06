#!/bin/sh

tier=$1
if [ -z "$tier" ]; then
  >&2 echo "Usage: ./bin/service-exec.sh _service_ [component]"
  exit 1
fi

component=$2
component=${component:-'server'}
echo "Opening a shell for service '$tier', component '$component'"
command="$3"
case $tier in
  matomo) default_command='/bin/bash' ;;
  *) default_command='/bin/sh' ;;
esac

if [ -n "$command" ]; then
  command="$3 $4 $5 $6 $7 $8 $9"
else
  command=${command:-$default_command}
fi

pod=$(kubectl get pod -l "tier=$tier,component=$component" -o=jsonpath='{.items[0].metadata.name}')
echo "Selected pod '$pod'"

cmd="kubectl exec -it $pod $command"
echo "Running '$cmd'"
$cmd
