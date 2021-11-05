#!/bin/bash
echo "COMM PID TID PSR %CPU"

while true;
do 
	pid="$(pgrep $1)"

	if [[ ! -z $pid ]]
	then
	#ps -mo ipd,tid,fname,user,psr,pcpu  -p $pid --no-headers;
		ps -p $pid -L -o comm,pid:1,tid:1,psr:1,pcpu:1 --no-headers
		#echo ""
	#usage="${str}"
	#echo $str
	fi
	sleep $2;
done

#echo $usage

#avg_total_runtime[$count]=$(python -c 'import statistics;import sys; print(statistics.median(sorted('$total_runtime'))/'$TIME_CONVERT'); sys.exit(0)')
