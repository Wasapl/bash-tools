#!/bin/bash

check_task_exists () {
    local tid="$1"

    local task_id=$(fuel task |awk -F'|' -v t=$tid '$1~t&&$3~/deployment/{print $1}')
    if [[ "x$task_id" == "x" ]]; then
        return 1
    else
        return 0
    fi
}

get_running_deployment_task() {
    local task_id=$(fuel task |awk -F'|' '$3~/deployment/&&$2~/running/{print $1}') 
    if [[ "x$task_id" == "x" ]]; then
        echo '0'
    else
        echo ${task_id}
    fi
}

print_task_stats() {
    local task_id=$1
    local print_errors={2:-"false"}

    [[ "x${print_errors}" == "false" ]] || awk_errors="true"

    fuel2 task history show $task_id|awk -F'|' -v pr=$awk_errors '
        BEGIN{r=0;p=0;e=0;s=0;}
        $4~/ready/{r++}
        $4~/pending/{p++}
        $4~/error/{e++;if(pr){print;}}
        $4~/skipped/{s++}
        END{
            print "total="NR;
            print "Ready="r; 
            print "Pending="p; 
            print "Skipped="s;
            print "ERROR="e;
        }
        '
}



if [[ "x$1" == "x" ]]; then 
    task_id=$(get_running_deployment_task)
    if [[ $task_id == '0' ]]; then
        echo 'There is no running deployment task right now. Please provide correct task_id.'
        exit 1
    else
        echo "Task_id=$task_id"
    fi
else 
    task_id=$1
    check_task_exists $task_id || echo "There is no deployment task with task_id=$task_id. Please provide correct task_id." && exit 1
fi

print_task_stats $task_id 