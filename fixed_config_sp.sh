#!/bin/bash
echo "START"
date

BIG_MAX_F=2000000
BIG_MIN_F=200000

LITTLE_MAX_F=1500000
LITTLE_MIN_F=200000

BIG_CORES=$4
LITTLE_CORES=$3
Fb=$6
Fl=$5

#Export enviroment variables to execute without the parsecmgnt
export PARSECDIR="/home/reginaldojunior/Documentos/UFscar/parsec-2.1"
export LD_LIBRARY_PATH="/home/Documentos/UFscar/parsec-2.1/pkgs/libs/hooks/inst/arm-linux.gcc-openmp-nornir/lib"
export OMP_PROC_BIND=true
export OMP_PLACES="{4},{5},{6},{7},{0},{1},{2},{3}"
#export OMP_NUM_THREADS=8 #freqmine

#Path variables
XU3EM_PATH="/home/Documentos/UFscar/XU3EM"
P3ARSEC_PATH="/home/Documentos/UFscar/parsec-2.1/pkgs/apps"
APP_PATH="$P3ARSEC_PATH/$1/inst/arm-linux.gcc-openmp/bin/$1"
RESULTS_PATH="$XU3EM_PATH/Results/Pareto"
sensors_bin="$XU3EM_PATH/Power_sensor/sensors"
check_aff="$XU3EM_PATH/Tools/check_aff.sh"
check_temp="$XU3EM_PATH/Tools/check_temp.sh"
stressng="/home/Documentos/UFscar/stress-ng/stress-ng"

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


    echo 'setting cpu temperature limits ...'
    # standard: 60, 70, 80, 115, 85, 90, 95
    for i in 0 1 2 3
    do
       echo -n 120000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_0_temp"
       echo -n 120000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_1_temp"
       echo -n 120000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_2_temp"
      #echo -n 150000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_3_temp"#critical
       echo -n 120000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_4_temp"
       echo -n 120000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_5_temp"
       echo -n 120000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_6_temp"
    done
    
    NUM_RUNS=$2

    TOTAL_CORES=$(echo $BIG_CORES+$LITTLE_CORES | bc )

    echo "TOTAL_CORES "$TOTAL_CORES
    
    if [ ! "$LITTLE_CORES" = "0" ];
      then
        
        CORE_RUN=0

        for ((i=1; i<$LITTLE_CORES; i=i+1))
        do
            CORE_RUN=$(echo "$CORE_RUN,$i")
        done   

        #CORE_RUN=${CORE_RUN%?} 
    fi; 

    if [ ! "$BIG_CORES" = "0" ];
      then
        if [ "$LITTLE_CORES" = "0" ];
        then
            CORE_RUN="4"
            FIRST=5
        else
            FIRST=4 
        fi; 

        for ((i=FIRST; i<$BIG_CORES+4; i=i+1))
        do 
            CORE_RUN=$(echo "$CORE_RUN,$i")
        done
        
    fi;

    echo "cset $CORE_RUN"
    cset shield -c "$CORE_RUN" -k on --force
    
    app_folder="$1_$(date +%Y_%m_%d_%H_%M_%S)"

    cpufreq-set -d $Fl -u $Fl -c 0 -g "performance"
    cpufreq-set -d $Fb    -u $Fb    -c 4 -g "performance"

    cpufreq-info -o    

    for i in $(seq 1 "$NUM_RUNS");
    do
        result_path_n="$RESULTS_PATH/$app_folder/${BIG_CORES}_${LITTLE_CORES}_${Fb}_${Fl}/Run_$i"
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
        $sensors_bin 1 1 500000000 > "$result_path_n/sensors.csv" &
        PID_sensors=$!
        sleep 1

        if [ "$1" = "blackscholes" ];
        then
           echo "Running $1 app"
           t1=$(date +'%s%N')
           cset shield -e $APP_PATH -- $TOTAL_CORES $P3ARSEC_PATH/$1/run/in_10M.txt $P3ARSEC_PATH/$1/run/prices.txt > /dev/null 2> /dev/null
           #$APP_PATH 8 $P3ARSEC_PATH/$1/run/in_4.txt $P3ARSEC_PATH/$1/run/prices.txt > /dev/null 2> /dev/null
           t2=$(date +'%s%N')
           echo "Finished $1 app"
        fi;

        if [ "$1" = "stressng" ];
        then
           echo "Running $1 app"
           t1=$(date +'%s%N')
           cset shield -e stressng -- --cpu $TOTAL_CORES --cpu-method callfunc -t 100 --taskset $CORE_RUN -k > /dev/null 2> /dev/null
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

        echo ""
      done

      echo 'fan automatic'
      echo 1 > "/sys/devices/platform/pwm-fan/hwmon/hwmon0/automatic"

      echo "return normal thermal temp values"
      #standard: 60, 70, 80, 115, 85, 90, 95
      for i in 0 1 2 3
      do
         echo -n 60000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_0_temp"
         echo -n 70000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_1_temp"
         echo -n 80000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_2_temp"
         #echo -n 150000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_3_temp"#critical
         echo -n 85000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_4_temp"
         echo -n 90000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_5_temp"
         echo -n 95000 > "/sys/devices/virtual/thermal/thermal_zone$i/trip_point_6_temp"
      done

      echo 'change frequency'
      cpufreq-set -d $LITTLE_MIN_F -u $LITTLE_MAX_F -c 0 -g "powersave"
      cpufreq-set -d $BIG_MIN_F    -u $BIG_MAX_F    -c 4 -g "powersave"
      echo "reset shield"
      cset shield --reset --force
else
    echo "Ping did not respond; IP address either free or firewalled" >&2
fi
