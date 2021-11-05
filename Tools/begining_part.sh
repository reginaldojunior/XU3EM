#!/bin/bash
#export OMP_PROC_BIND=true

#cset shield -c $3 -k on --force
export OMP_PROC_BIND=true
export OMP_PLACES="{4},{5},{6},{7},{0},{1},{2},{3}"

cset shield -c $3 -k on --force
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

echo "===Sanity check.==="

cpufreq-set -d $1 -u $1 -c 4 -g performance
cpufreq-set -d $2 -u $2 -c 0 -g performance
