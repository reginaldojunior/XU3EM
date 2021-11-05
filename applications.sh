#!/bin/bash

#export OMP_PROC_BIND=true

echo -e "#Name\tStart(ns)\tEnd(ns)"

DIR="$( cd "$( dirname "$BASH_SOURCE[0]}" )" && pwd )"

if [ -f /$DIR/bench_list.data ]
then
	benchmarks=$(grep -v ^# /$DIR/bench_list.data)
else
	benchmarks=*  
fi

for i in $benchmarks
do


	if [ $i == "swaptions" ]
	then
		t1=$(date +'%s%N')
		cset shield -e /$DIR/pkgs/apps/swaptions/inst/arm-linux.gcc-openmp/bin/swaptions -- -ns 128 -sm 1000000 -nt $1 > /dev/null 2> /dev/null #8threads
		t2=$(date +'%s%N')
	fi

	if [ $i == "bodytrack" ]
	then
		t1=$(date +'%s%N')
		cset shield -e /$DIR/pkgs/apps/bodytrack/inst/arm-linux.gcc-openmp/bin/bodytrack -- /$DIR/pkgs/apps/bodytrack/run/sequenceB_261 4 261 4000 5 0 $1 > /dev/null 2> /dev/null #nthreads
		t2=$(date +'%s%N')
	fi

	if [ $i == "freqmine" ]
	then
		export OMP_NUM_THREADS=$1
		echo "FREQMINE $OMP_NUM_THREADS"
		t1=$(date +'%s%N')
		cset shield -e  /$DIR/pkgs/apps/freqmine/inst/arm-linux.gcc-openmp/bin/freqmine -- /$DIR/pkgs/apps/freqmine/run/webdocs_250k.dat 11000 > /dev/null 2> /dev/null
		t2=$(date +'%s%N')
	fi

	if [ $i == "blackscholes" ]
	then
		t1=$(date +'%s%N')
		cset shield -e /$DIR/pkgs/apps/blackscholes/inst/arm-linux.gcc-openmp/bin/blackscholes -- $1 /$DIR/pkgs/apps/blackscholes/run/in_10M.txt /$DIR/pkgs/apps/blackscholes/run/prices.txt  > /dev/null 2> /dev/null #n thread
		t2=$(date +'%s%N')
	fi

	if [ $i == "smallpt" ]
	then
		t1=$(date +'%s%N')
		cset shield -e /var/lib/phoronix-test-suite/installed-tests/pts/smallpt-1.2.0/smallpt-renderer 128 > log.txt 2>&1
		t2=$(date +'%s%N')
	fi	

	if [ $i == "graphicsmagick" ]
	then
	
		t1=$(date +'%s%N')
		cset shield -e /var/lib/phoronix-test-suite/installed-tests/pts/graphics-magick-1.8.0/gm_/bin/./gm -- convert /var/lib/phoronix-test-suite/installed-tests/pts/photo-sample-1.0.1/DSC_6782.png -operator all Noise-Gaussian "30%" out.png > log.txt 2>&1
		t2=$(date +'%s%N')
	fi	
	
	if [ $i == "x264" ]
	then
	
		t1=$(date +'%s%N')
		cset shield -e /var/lib/phoronix-test-suite/installed-tests/pts/x264-2.5.0/x264_/bin/x264 -- -o /dev/null --preset slow  /var/lib/phoronix-test-suite/installed-tests/pts/x264-2.5.0/Bosphorus_1920x1080_120fps_420_8bit_YUV.y4m > /dev/null 2> /dev/null
		t2=$(date +'%s%N')
	fi	

	if [ $i == "kmeans" ]
	then
		t1=$(date +'%s%N')
		cset shield -e /home/demetrios/Projects/rodinia_3.1/openmp/kmeans/kmeans_openmp/kmeans -- -n $1 -i /home/demetrios/Projects/rodinia_3.1/data/kmeans/1000000_34f.txt > /dev/null 2> /dev/null
		t2=$(date +'%s%N')
	fi			
    if [ $i == "particle" ]
    then
    	echo 'particle'
        t1=$(date +'%s%N')
        cset shield -e /home/demetrios/Projects/rodinia_3.1/openmp/particlefilter/particle_filter -- -x 128 -y 128 -z 400 -np 16384 > /dev/null 2> /dev/null
        t2=$(date +'%s%N')
    fi 	
    
    if [ $i == "lavamd" ]
    then
    	echo 'lavamd'
        t1=$(date +'%s%N')
        cset shield -e /home/demetrios/Projects/rodinia_3.1/openmp/lavaMD/lavaMD -- -cores $1 -boxes1d 24 > /dev/null 2> /dev/null
        t2=$(date +'%s%N')
    fi 	

	echo -e "$i\t$t1\t$t2"
done
