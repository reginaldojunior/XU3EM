#!/bin/bash

echo "START"
date

#export OMP_PROC_BIND=true
export OMP_PLACES="{4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7}"
#export OMP_NUM_THREADS=8 #freqmine

echo "OMP_PLACES2 $OMP_PLACES"

parsec_app=parsec.$2

PATH_PARSEC=../Workloads/parsec-3.0
PATH_RESULTS=../Results

sed -i "/#/! s/^/#/" $PATH_PARSEC/bench_list.data #MAKE SURE EACH LINE HAS # character

cat $PATH_PARSEC/bench_list.data

echo ' '

sed -i "/$parsec_app/   s/.//" $PATH_PARSEC/bench_list.data  #editing the bench_list.data to run the specific parsec application

cat $PATH_PARSEC/bench_list.data

echo ' '

echo "START"

#echo "TEST"
#date
#./MC_XU3_PARETO.sh -b 1 -L 1 -f 700000,700000,800000 -q 400000,600000,400000 -n 1 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/blacktest_1_1_/noevents/


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

    if [ "$b" = "0" ]
    then
	   echo "B = 0"
	   ./MC_XU3_PARETO.sh -L $L -f $fL -n 3 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_h/$2_${b}_${L}/
    elif [ "$L" = "0" ]
    then
	   echo "L ==0"
        ./MC_XU3_PARETO.sh -b $b -f $fb -n 3 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_h/$2_${b}_${L}/
    else
	   echo "L AND B IS NOT ZERO"
	   ./MC_XU3_PARETO.sh -b $b -L $L -f $fb -q $fL -n 3 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_h/$2_${b}_${L}/
    fi

#    ./MC_XU3_PARETO.sh -b $b -L $L -f $fb -q fL -n 3 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/modelfit/bodytrack_$b_$l_/

done < $1



sed -i "/$parsec_app/   s/^/#/" $PATH_PARSEC/bench_list.data #Add the # character

cat $PATH_PARSEC/bench_list.data

echo "END"
date
