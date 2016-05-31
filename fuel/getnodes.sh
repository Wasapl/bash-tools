#!/bin/bash

DEBUG=false
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
  echo "fuel node --list $env | awk -F '|' -v s=$status -v r=$role 'NR>2 && \$7~r && \$2~s {print \$1}'"
  echo
  echo
fi

fuel node --list $env 2>/dev/null | awk -F '|' -v s=$status -v r=$role 'NR>2 &&$7~r &&$2~s {print $1}' | sort -n

