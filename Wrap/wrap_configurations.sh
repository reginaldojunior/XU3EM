#!/bin/bash

echo "START"
date

#export OMP_NUM_THREADS=8 #freqmine

fixedconfig="/home/demetrios/Projects/XU3EM/fixed_config_sp.sh"

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

    fixedconfig "stressng" 1 $L $b $fL $fb

done < $1

