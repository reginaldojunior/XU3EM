#!/bin/bash

#Export enviroment variables to execute without the parsecmgnt
export PARSECDIR="/home/demetrios/Projects/p3arsec"
export LD_LIBRARY_PATH="/home/demetrios/Projects/p3arsec/pkgs/libs/hooks/inst/arm-linux.gcc-openmp-nornir/lib"

export OMP_PROC_BIND=true
export OMP_PLACES="{4},{5},{6},{7},{0},{1},{2},{3}"

#Path variables
XU3EM_PATH="/home/demetrios/Projects/XU3EM"
P3ARSEC_PATH="/home/demetrios/Projects/p3arsec/pkgs/apps"
APP_PATH="$P3ARSEC_PATH/$1/inst/arm-linux.gcc-openmp-nornir/bin/$1"
RESULTS_PATH="$XU3EM_PATH/Results/nornir"
sensors_bin="$XU3EM_PATH/Power_sensor/sensors"

NUM_RUNS=$2
app_folder="$1_$(date +%Y_%m_%d_%H_%M_%S)"

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

	for n in $(seq 1 "$NUM_RUNS");
	do  
	   echo "***Run $n of $NUM_RUNS***"

	   cpufreq-set -d 2000000  -u 2000000 -c 4 -g powersave
	   cpufreq-set -d 1500000  -u 1500000 -c 0 -g powersave

	   result_path_n="$RESULTS_PATH/$app_folder/Run_$n"
	   mkdir -v -p $result_path_n
	
	   echo ""

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

	   kill `cat /tmp/smartpower_m.lock`

	   echo -e "$1\t$t1\t$t2" > "$result_path_n/benchmark.csv"

	   echo "Moving results from folder $1/Run"
	   #mv -v "benchmark.out" "$result_path_n"
	   mv -v "calibration.csv" "$result_path_n"
	   mv -v "stats.csv" "$result_path_n"
	   mv -v "summary.csv" "$result_path_n"

	   echo ""
	done

	#cd "$RESULTS_PATH"
	#tar -czvf "$app_folder.tar.gz" "$app_folder/"
	#cd -

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

	#Put back fan on automatic mode
	echo 1 > "/sys/devices/platform/pwm-fan/hwmon/hwmon0/automatic"

else
    echo "Ping did not respond; IP address either free or firewalled" >&2
fi


