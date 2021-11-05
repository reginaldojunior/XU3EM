#!/bin/bash
cset shield --reset --force

#Put back fan on automatic mode
echo 1 > "/sys/devices/platform/pwm-fan/hwmon/hwmon0/automatic"

#sudo cpufreq-set -g ondemand
cpufreq-set -d 200000 -u 200000 -c 4 -g powersave
cpufreq-set -d 200000 -u 200000 -c 0 -g powersave

echo "===Sanity check.==="
cpufreq-info
echo "==="
cset shield

echo "return normal thermal temp values"
# standard: 60, 70, 80, 115, 85, 90, 95
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
