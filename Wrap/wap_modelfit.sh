#!/bin/bash

echo "START"
date
PATH_CPUBOUND=/home/demetrios/Projects/XU3EM/ODROID_XU3/cpu_bound
PATH_RESULTS=../Results

while read line
do
    b=$line
    read line
	L=$line
	read line
	fb=$line
	read line
	fL=$line

    echo "$b $L"
    echo "$fb"
    echo "$fL"
   #echo "L AND B IS NOT ZERO"
	./MC_XU3_PARETO.sh -b $b -L $L -f $fb -q $fL -n 1 -x $PATH_CPUBOUND/model_stress.sh -t 500000000 -s $PATH_RESULTS/modelfit_30_halton/$2_${b}_${L}/

done < $1

echo "END"
date
