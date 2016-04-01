#!/bin/bash 

DEBUG=false
env=""
status=""
role=""
while getopts "e:r:s:" arg; do
  case $arg in
    e )
      env="-e $OPTARG"
      ;;
    s )
      status="-s $OPTARG"
      ;;
    r )
      role="-r $OPTARG"
      ;;
    * )
      echo "Usage:
$0 [-e <env>] [-s status] [-r role] 'command'"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$DEBUG" = true ]; then
  echo "env $env"
  echo "Role $role"
fi

for no in `./getnodes.sh $env $status $role`; do echo $no; ssh node-$no $* 2\>\&1 2>/dev/null; done
