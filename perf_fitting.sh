#!/bin/bash
FREQ_MIN=200000 #200000
FREQ_MAX=1500000 #1500000
STEP=100000

NUM_RUNS=5
ITERATIONS=270000000 #270000000 - 11 secs big higher freq

cpufreq-set -d 2000000 -u 2000000 -c 4 -g performance
cpufreq-set -d 1400000 -u 1400000 -c 0 -g performance

echo 'fan on MAX'
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

echo -e "CLUSTER\tRUN\tFREQ\tTIME_START\tTIME_END" > data

for CLUSTER in 0 4
do
	echo 'CLUSTER ' $CLUSTER
	cset shield -c $CLUSTER -k on --force
	for i in $(seq 1 $NUM_RUNS)
	do
		echo "$i/$NUM_RUNS"

		for FREQ in $(seq $FREQ_MIN $STEP $FREQ_MAX)
	 	do
			cpufreq-set -d $FREQ -u $FREQ -c $CLUSTER
			cpufreq-info -o
			
			t1=$(date +'%s%N')
			#cset shield -e ./cpuload -- $ITERATIONS
			cset shield -e /home/demetrios/Projects/stress-ng/stress-ng -- --cpu 1 --cpu-method callfunc --exec-ops 87555  > /dev/null 2> /dev/null
			t2=$(date +'%s%N')

			echo -e "$CLUSTER\t$i\t$FREQ\t$t1\t$t2" >> data
		done
	done
	cset shield --reset --force
done

cpufreq-set -d 2000000 -u 2000000 -c 4 -g performance
cpufreq-set -d 1400000 -u 1400000 -c 0 -g performance

cset shield 
cpufreq-info -o

#Put back fan on automatic mode
echo 1 > "/sys/devices/platform/pwm-fan/hwmon/hwmon0/pwm1"

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

echo "Script End! :)"
exit