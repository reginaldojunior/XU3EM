#!/bin/bash

#method=$(cat /home/demetrios/Projects/XU3EM/ODROID_XU3/cpu_bound/method.temp)
t1=$(date +'%s%N')
cset shield -e /home/demetrios/Projects/stress-ng/stress-ng -- --cpu $1 --cpu-method callfunc -t 75 --taskset $2 -k > /dev/null 2> /dev/null
t2=$(date +'%s%N')	

echo -e "#Name\tStart(ns)\tEnd(ns)"
echo -e "stress\t$t1\t$t2"