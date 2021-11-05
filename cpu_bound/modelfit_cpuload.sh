#!/bin/bash

IFS=',' read -r -a cores <<< "$2"
t1=$(date +'%s%N')
for i in "${cores[@]}"
do
	cset shield -e taskset -- -c $i /home/demetrios/Projects/XU3EM/ODROID_XU3/cpu_bound/cpuload -t 76 > /dev/null 2> /dev/null &
	pids[${i}]=$!
done

# wait for all pids
for pid in ${pids[*]}; do
    wait $pid
done

t2=$(date +'%s%N')
	

echo -e "#Name\tStart(ns)\tEnd(ns)"
echo -e "modelfit\t$t1\t$t2"

