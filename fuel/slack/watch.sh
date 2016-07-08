#!/bin/bash

ENV=

DB='su - postgres' 

while getopts "e:" arg; do
  case $arg in
    e )
      ENV="$OPTARG"
      # TODO check that env exists
      ;;
    * )
      echo "Usage:
$0 [-e <env>]"
      exit 1
      ;;
  esac
done

# get env status from db
env_status=$(su - postgres -c "psql -A nailgun -P 'tuples_only' -c \"select status from clusters where id=${ENV};\"")
env_name=$(su - postgres -c "psql -A nailgun -P 'tuples_only' -c \"select name from clusters where id=${ENV};\"")

# get tasks for this env from db
#get deplyment task_id
task_id=$(fuel task |awk -F'|' -v cl=${ENV} 'BEGIN{tid=0}NR>2&&$3~/deployment/&&$4==cl{if(tid<$1){tid=$1}}END{print tid;}')
echo $task_id
stats=$(./tasks2.sh $task_id)
echo ${stats}

# curl to slack
./slack.sh "Env ${env_name} is in ${env_status} state.\n${stats}"
