#!/bin/sh

tier=$1
local_port=$2
remote_port=0
if [ -z "$tier" ]; then
  >&2 echo "Usage: ./bin/service-exec.sh _service_ [local_port]"
  exit 1
fi

case $tier in
  apex)
    tier=argu
    remote_port=3000
    ;;
  email | token)
    remote_port=3000
    ;;
  frontend)
    remote_port=3000
    ;;
  *)
    echo "unknown service $tier"
    exit 1
    ;;
esac

local_port=${local_port:-"${remote_port}0"}

cmd="kubectl port-forward svc/$tier $local_port:$remote_port"
echo "Running '$cmd'"
$cmd
