#!/bin/bash +x

nodestr=$( fuel node --list | awk -F '|'  'BEGIN{OFS="=";ORS="|"}NR>2 {print $1,$7}' )
echo $nodestr
IFS="|" read -r -a nodes <<< "$nodestr"
for node in "${nodes[@]}"
do
  echo "a=\"$node\""
  IFS='=' read -r -a arr <<< "$node" 
  var=${arr[0]}
  var="${var%"${var##*[![:space:]]}"}"
  scp ./motd node-${var}:/etc/motd
  ssh node-${arr[0]} "echo ROLES: ${arr[1]}>>/etc/motd"
done
