#!/bin/bash
echo "START"
date

BIG_MAX_F=2000000
BIG_MIN_F=200000

LITTLE_MAX_F=1500000
LITTLE_MIN_F=200000

SAVE_DIR=/home/demetrios/Projects/XU3EM/Results/governors

#export OMP_PROC_BIND=true
export OMP_PLACES="{4},{5},{6},{7},{0},{1},{2},{3}"
#export OMP_NUM_THREADS=8 #freqmine

echo "OMP_PLACES2 $OMP_PLACES"

cset shield -c 0-7 -k on --force

#Turn on fan on max power to avoid throttling on 4 cores.
#Start manual mode
echo 0 > "/sys/devices/platform/pwm-fan/hwmon/hwmon0/automatic"
#Put fan on MAX RPM
echo 255 > "/sys/devices/platform/pwm-fan/hwmon/hwmon0/pwm1"

governos=("ondemand" "powersave" "performance")
bench=("lavamd")
for b in ${bench[@]}
do
   for g in ${governos[@]}
   do
      cpufreq-set -d 200000 -u 1500000 -c 0 -g "$g" 
      cpufreq-set -d 200000 -u 2000000 -c 4 -g "$g"   	

      for i in 1 2 3 4 5
      do
         ./sensors 1 1 500000000 > "sensors.data" &
         PID_sensors=$!
         disown

         ./check_aff.sh "$b" 2 > "$b$g.aff" &
         PID_check=$!
         disown    

         ./check_temp.sh 2 > "$b$g.temp" &
         PID_temp=$!
         disown        

         echo ""
         echo "run $b $g $i"
         echo ""
         echo -e "#Start(ns)\tEnd(ns)" > runtime.data
         #printf "%s" $(date +'%s%N') >> runtime.data

         if [ $b == "bodytrack" ]
         then
            echo "b"
            t1=$(date +'%s%N')
            cset shield -e /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/bodytrack/inst/arm-linux.gcc-openmp/bin/bodytrack -- /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/bodytrack/run/sequenceB_261 4 261 4000 5 0 8 > /dev/null 2> /dev/null #nthreads
            t2=$(date +'%s%N')
         fi

         if [ $b == "freqmine" ]
         then
            echo "f"
            t1=$(date +'%s%N')
            cset shield -e  /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/freqmine/inst/arm-linux.gcc-openmp/bin/freqmine -- /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/freqmine/run/webdocs_250k.dat 11000 > /dev/null 2> /dev/null
            t2=$(date +'%s%N')
         fi

         if [ $b == "blackscholes" ]
         then
            echo "bl"
            t1=$(date +'%s%N')
            cset shield -e /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/blackscholes/inst/arm-linux.gcc-openmp/bin/blackscholes -- 8 /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/blackscholes/run/in_10M.txt /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/blackscholes/run/prices.txt > /dev/null 2> /dev/null #n thread
            t2=$(date +'%s%N')
         fi    

         if [ $b == "smallpt" ]
         then
         	echo "st"
            t1=$(date +'%s%N')
            cset shield -e /var/lib/phoronix-test-suite/installed-tests/pts/smallpt-1.2.0/smallpt-renderer 128 > log.txt 2>&1
            t2=$(date +'%s%N')
         fi

         if [ $b == "graphicsmagick" ]
         then
         	echo "gm"
            t1=$(date +'%s%N')
            cset shield -e /var/lib/phoronix-test-suite/installed-tests/pts/graphics-magick-1.8.0/gm_/bin/./gm -- convert /var/lib/phoronix-test-suite/installed-tests/pts/photo-sample-1.0.1/DSC_6782.png -operator all Noise-Gaussian "30%" out.png > log.txt 2>&1
            t2=$(date +'%s%N')
         fi       
         if [ $b == "x264" ]
		 then
		 	echo 'x264'
			t1=$(date +'%s%N')			
			cset shield -e /var/lib/phoronix-test-suite/installed-tests/pts/x264-2.5.0/x264_/bin/x264 -- -o /dev/null --preset slow  /var/lib/phoronix-test-suite/installed-tests/pts/x264-2.5.0/Bosphorus_1920x1080_120fps_420_8bit_YUV.y4m > /dev/null 2> /dev/null
			t2=$(date +'%s%N')
		 fi

	     if [ $b == "kmeans" ]
	     then
	       echo 'kmeans'
		   t1=$(date +'%s%N')
		   cset shield -e /home/demetrios/Projects/rodinia_3.1/openmp/kmeans/kmeans_openmp/kmeans -- -n 8 -i /home/demetrios/Projects/rodinia_3.1/data/kmeans/1000000_34f.txt > /dev/null 2> /dev/null
		   t2=$(date +'%s%N')
		 fi	
       if [ $b == "particle" ]
        then
         echo 'particle'
         t1=$(date +'%s%N')
         cset shield -e /home/demetrios/Projects/rodinia_3.1/openmp/particlefilter/particle_filter -- -x 128 -y 128 -z 400 -np 16384 > /dev/null 2> /dev/null
         t2=$(date +'%s%N')
       fi    

       if [ $b == "lavamd" ]
       then
         echo 'lavamd'
         t1=$(date +'%s%N')
         cset shield -e /home/demetrios/Projects/rodinia_3.1/openmp/lavaMD/lavaMD -- -cores 8 -boxes1d 24 > /dev/null 2> /dev/null
         t2=$(date +'%s%N')
       fi                				 
         #cset shield -e /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/swaptions/inst/arm-linux.gcc-openmp/bin/swaptions -- -ns 128 -sm 1000000 -nt 8 > /dev/null 2> /dev/null #8threads
         #cset shield -e /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/freqmine/inst/arm-linux.gcc-openmp/bin/freqmine -- /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/freqmine/run/webdocs_250k.dat 11000
         #cset shield -e /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/bodytrack/inst/arm-linux.gcc-openmp/bin/bodytrack -- /home/demetrios/Projects/XU3EM/Workloads/parsec-3.0/pkgs/apps/bodytrack/run/sequenceB_261 4 261 4000 5 0 8
         #printf "\t%s\n" $(date +'%s%N') >> runtime.data
         echo -e "$i\t$t1\t$t2" >> runtime.data

         echo 'kill watchdogs'
         sleep 1
         kill $PID_sensors > /dev/null
         kill $PID_check > /dev/null
         kill $PID_temp > /dev/null
         sleep 1

         mkdir -v -p "$SAVE_DIR/$b/$g/Run_$i"
         echo "Copying results to chosen dir: $SAVE_DIR/$b/$g/Run_$i"
         cp -v "sensors.data" "runtime.data"  "$SAVE_DIR/$b/$g/Run_$i"
         rm -v "sensors.data" "runtime.data"   
      done
   done
done

echo 'reset shield'
cset shield --reset --force
echo 'fan automatic'
echo 1 > "/sys/devices/platform/pwm-fan/hwmon/hwmon0/automatic"

echo 'change frequency'
cpufreq-set -d 200000 -u 200000 -c 4
cpufreq-set -d 140000 -u 140000 -c 0 
