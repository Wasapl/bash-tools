#!/bin/bash

DEBUG=false
BY_NAME=true  #true - returns nodes names like 'node-xx', false - returns IP addresses

env=""
status=".*"
role=".*"

while getopts "e:s:r:" arg; do
  case $arg in
    e )
      env="--env $OPTARG"
      ;;
    s )
      status="$OPTARG"
      ;;
    r )
      role="$OPTARG"
      ;;
    * )
      echo "Usage:
$0 [-e <env>] [-s status] [-r role]"
      exit 1
      ;;
  esac
done


if [ "$DEBUG" = true ]; then
  echo "env $env"
  echo "Role $role"
  echo "Status $status"
  echo "fuel node --list $env 2>/dev/null | sort -n | awk -F '|' -v s=$status -v r=$role -v f=$BY_NAME 'NR>2 &&$7~r &&$2~s {if(f==\"true\"){print \"node-\"$1}else{print $5}}'"
  echo
  echo
fi

fuel node --list $env 2>/dev/null | sort -n | awk -F '|' -v s="$status" -v r="$role" -v f=$BY_NAME 'NR>2 &&$7~r &&$2~s {if(f=="true"){print "node-"$1}else{print $5}}'

