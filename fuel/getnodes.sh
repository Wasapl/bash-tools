#!/bin/bash

DEBUG=false
env=""
role=".*"
while getopts "e:r:" arg; do
  case $arg in
    e )
      env="--env $OPTARG"
      ;;
    r )
      role="$OPTARG"
      ;;
    * )
      echo "Usage:
$0 [-e <env>] [-r role]"
      exit 1
      ;;
  esac
done

if [ "$DEBUG" = true ]; then
  echo "env $env"
  echo "Role $role"
  echo "fuel node --list $env | awk -F '|' -v r=$role 'NR>2 && \$ 7~r {print \$ 1}'"
  echo
  echo
fi

fuel node --list $env 2 >/dev/null | awk -F '|' -v r=$role 'NR>2 &&$7~r {print $1}'

