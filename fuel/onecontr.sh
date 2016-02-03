#!/bin/bash 

DEBUG=false
env=""
role=""
while getopts "p:e:" arg; do
  case $arg in
    p )
      prim=$OPTARG
      ;;
    e )
      env="-e $OPTARG"
      ;;
    * )
      echo "Usage:
$0 [-p <primary controller>] [-e <env>] 'command'"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

for no in `./getnodes.sh $env -r controller`; do
  if [ "$no" -ne "$prim" ]; then
    echo $no; 
    ssh node-$no $* 2\>\&1 2>/dev/null; 
  fi
done
