#!/bin/bash

echo "START"
date

#export OMP_PROC_BIND=true
export OMP_PLACES="{4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7}"
echo "OMP_PROC_BIND " $OMP_PROC_BIND
echo "OMP_PLACES " $OMP_PLACES
#export OMP_NUM_THREADS=8 #freqmine

parsec_app=parsec.swaptions

PATH_PARSEC=../Workloads/parsec-3.0
PATH_RESULTS=../Results

sed -i "/#/! s/^/#/" $PATH_PARSEC/bench_list.data #MAKE SURE EACH LINE HAS # character

cat $PATH_PARSEC/bench_list.data

echo ' '

sed -i "/$parsec_app/   s/.//" $PATH_PARSEC/bench_list.data  #editing the bench_list.data to run the specific parsec application

cat $PATH_PARSEC/bench_list.data

echo ' '


#1Core LITTLE TO DO LATER
#echo "START"
#date
#./MC_XU3.sh -L 1 -f 1400000 -n 5 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/bodytrack_1l/noevents/

#All Cores
#./MC_XU3.sh -b 4 -L 4 -f 1800000,1500000,1200000  -q 1400000,1000000,600000 -n 2 -x /home/demetrios/Projects/ODROID/ARMPM_datacollect/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -t 500000000 -s /home/demetrios/Projects/ODROID/ARMPM_datacollect/Results/cset_perfcpu_PARSEC_bodytrack_eMMC_c8_testfreq/noevents/
#./MC_XU3.sh -b 4 -L 4 -f 1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 1300000 -n 2 -x $PATH_PARSEC/parsec_benchlist_timestamp_cset.sh -t 500000000 -s $PATH_RESULTS/freqmine_1300l_2/noevents/
#./MC_XU3.sh -b 4 -L 4 -f 1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -n 5 -x $PATH_PARSEC/parsec_benchlist_timestamp_cset.sh -t 500000000 -s $PATH_RESULTS/sw_1200l_/noevents/


#./MC_XU3.sh -b 4 -L 4 -f 1200000 -q 1400000 -n 1 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_test/noevents/


echo "PART 1400l"
date
./MC_XU3.sh -b 4 -L 4 -f 1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 1400000 -n 5 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_one_thread_on_any_big/1400l_allbig/noevents/

echo "PART 1300l"
date
./MC_XU3.sh -b 4 -L 4 -f 1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 1300000,1200000 -n 5 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_one_thread_on_any_big/1300l_allbig/noevents/

echo "PART 1100l"
date
./MC_XU3.sh -b 4 -L 4 -f 1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 1100000,1000000 -n 5 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_one_thread_on_any_big/1100l_allbig/noevents/

echo "PART 900l"
date
./MC_XU3.sh -b 4 -L 4 -f 1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 900000,800000 -n 5 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_one_thread_on_any_big/900l_allbig/noevents/

echo "PART 700l"
date
./MC_XU3.sh -b 4 -L 4 -f 1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 700000,600000 -n 5 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_one_thread_on_any_big/700l_allbig/noevents/

echo "PART 500l"
date
./MC_XU3.sh -b 4 -L 4 -f 1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 500000,400000 -n 5 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_one_thread_on_any_big/500l_allbig/noevents/

echo "PART 300l"
date
./MC_XU3.sh -b 4 -L 4 -f 1800000,1700000,1600000,1500000,1400000,1300000,1200000,1100000,1000000,900000,800000,700000,600000,500000,400000,300000,200000 -q 300000,200000 -n 5 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/swaptions_one_thread_on_any_big/300l_allbig/noevents/


#echo "TEST"
#date
#./MC_XU3.sh -b 4 -L 4 -f 1800000 -q 200000 -n 1 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/blacktest/noevents/


sed -i "/$parsec_app/   s/^/#/" $PATH_PARSEC/bench_list.data #Add the # character

cat $PATH_PARSEC/bench_list.data

echo "END"
date
