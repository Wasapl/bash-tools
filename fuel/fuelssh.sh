#!/bin/bash 

DEBUG=false
env=""
status=""
role=""
while getopts "e:s:r:" arg; do
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

for no in `./getnodes.sh $env $status $role`; do
  echo $no
  ssherr="$(mktemp)"
  ssh $no $* 2\>\&1 2>$ssherr
  if [ $? -ne 0 ]; then
    cat $ssherr
  fi
done
