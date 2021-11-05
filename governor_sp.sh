#!/bin/bash
echo "START"
date

BIG_MAX_F=2000000
BIG_MIN_F=200000

LITTLE_MAX_F=1500000
LITTLE_MIN_F=200000

SAVE_DIR=/home/demetrios/Projects/XU3EM/Results/governors
#Export enviroment variables to execute without the parsecmgnt
export PARSECDIR="/home/demetrios/Projects/p3arsec"
export LD_LIBRARY_PATH="/home/demetrios/Projects/p3arsec/pkgs/libs/hooks/inst/arm-linux.gcc-openmp-nornir/lib"
export OMP_PROC_BIND=true
export OMP_PLACES="{4},{5},{6},{7},{0},{1},{2},{3}"
#export OMP_NUM_THREADS=8 #freqmine

#Path variables
XU3EM_PATH="/home/demetrios/Projects/XU3EM"
P3ARSEC_PATH="/home/demetrios/Projects/p3arsec/pkgs/apps"
APP_PATH="$P3ARSEC_PATH/$1/inst/arm-linux.gcc-openmp/bin/$1"
RESULTS_PATH="$XU3EM_PATH/Results/governors"
sensors_bin="$XU3EM_PATH/Power_sensor/sensors"

echo "OMP_PLACES2 $OMP_PLACES"

#cset shield -c 0-7 -k on --force

#---
if ping -c1 -w3 192.168.4.1 >/dev/null 2>&1
then

    #Turn on fan on max power to avoid throttling on 4 cores.
    #Start manual mode
    echo 0 > "/sys/devices/platform/pwm-fan/hwmon/hwmon0/automatic"
    #Put fan on MAX RPM
    echo 255 > "/sys/devices/platform/pwm-fan/hwmon/hwmon0/pwm1"

    governos=("ondemand" "powersave" "performance" "conservative" "schedutil")
    
    NUM_RUNS=$2
    app_folder="$1_$(date +%Y_%m_%d_%H_%M_%S)"

    for g in ${governos[@]}
    do
      cpufreq-set -d $LITTLE_MIN_F -u $LITTLE_MAX_F -c 0 -g "$g"
      cpufreq-set -d $BIG_MIN_F    -u $BIG_MAX_F    -c 4 -g "$g"

      for i in $(seq 1 "$NUM_RUNS");
      do
        result_path_n="$RESULTS_PATH/$app_folder/$g/Run_$i"
        mkdir -v -p $result_path_n
      
        echo ""

        echo "starting checkings"
        $check_aff blackscholes 1 > "$result_path_n/aff.csv" &
        PID_aff=$!

        $check_temp 1 > "$result_path_n/temp.csv" &
        PID_temp=$!

         echo "starting daemon"
         $XU3EM_PATH/Power_sensor/sp_monitor 192.168.4.1 23 $result_path_n/sp_data.csv

         echo "starting INA sensors"
         $sensors_bin 1 1 500000000 > "$result_path_n/sensors.data" &
         PID_sensors=$!
         sleep 1

         if [ "$1" = "blackscholes" ];
         then
            echo "Running $1 app"
            t1=$(date +'%s%N')
            $APP_PATH 8 $P3ARSEC_PATH/$1/run/in_10M.txt $P3ARSEC_PATH/$1/run/prices.txt > /dev/null 2> /dev/null
            #$APP_PATH 8 $P3ARSEC_PATH/$1/run/in_4.txt $P3ARSEC_PATH/$1/run/prices.txt > /dev/null 2> /dev/null
            t2=$(date +'%s%N')
            echo "Finished $1 app"

         fi;

         echo ""

         sleep 1
         
         echo "killing monitor&sensor"
         kill $PID_sensors > /dev/null
         disown

         echo "kiling checkers"
         kill $PID_aff > /dev/null
         disown
        
         kill $PID_temp > /dev/null
         disown         

         kill `cat /tmp/smartpower_m.lock`

         echo -e "$1\t$t1\t$t2" > "$result_path_n/benchmark.csv"

         #echo "Moving results"
         #mv -v "calibration.csv" "$result_path_n"
         #mv -v "stats.csv" "$result_path_n"
         #mv -v "summary.csv" "$result_path_n"

         echo ""
      done
    done
    
    echo 'fan automatic'
    echo 1 > "/sys/devices/platform/pwm-fan/hwmon/hwmon0/automatic"

    echo 'change frequency'
    cpufreq-set -d $LITTLE_MIN_F -u $LITTLE_MAX_F -c 0 -g "powersave"
    cpufreq-set -d $BIG_MIN_F    -u $BIG_MAX_F    -c 4 -g "powersave"
else
    echo "Ping did not respond; IP address either free or firewalled" >&2
fi
