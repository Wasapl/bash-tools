#!/bin/bash 

DEBUG=false
env=""
role=""
while getopts "e:r:" arg; do
  case $arg in
    e )
      env="-e $OPTARG"
      ;;
    r )
      role="-r $OPTARG"
      ;;
    * )
      echo "Usage:
$0 [-e <env>] [-r role] 'command'"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$DEBUG" = true ]; then
  echo "env $env"
  echo "Role $role"
fi

for no in `./getnodes.sh $env $role`; do echo $no; ssh node-$no $1 2>/dev/null; done
