#!/bin/bash

echo -e "timestamp \tVIRTUAL_SCALING \tCPU0_FREQ \tCPU1_FREQ \tCPU2_FREQ \tCPU3_FREQ \tCPU4_FREQ \tCPU5_FREQ \tCPU6_FREQ \tCPU7_FREQ \tGPU_FREQ \tCPU_GOVERNOR \tCPU0_TEMP \tCPU1_TEMP \tCPU2_TEMP \tCPU3_TEMP \tGPU_TEMP"

# Main infinite loop
while true; do

# CPU Governor
CPU_GOVERNOR=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

#----scaling frequency and virtual temp -----
#scaling freq
for i in {0..7}
do
   CPU0_FREQ[i]=$((`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq`/1000))
done

#virtual temp
for i in {0..4}
do
   TEMP[i]=$((`cat /sys/devices/virtual/thermal/thermal_zone$i/temp`/1000))

   if (( ${TEMP[i]} > 100000 )); then
   		kill $2
   fi

done

GPU_FREQ=$((`cat /sys/bus/platform/drivers/mali/11800000.mali/devfreq/devfreq0/cur_freq`/1000000))

echo -e "$(date +'%s%N') \t1 \t${CPU0_FREQ[0]} \t${CPU0_FREQ[1]} \t${CPU0_FREQ[2]} \t${CPU0_FREQ[3]} \t${CPU0_FREQ[4]} \t${CPU0_FREQ[5]} \t${CPU0_FREQ[6]} \t${CPU0_FREQ[7]} \t$GPU_FREQ \t$CPU_GOVERNOR \t${TEMP[0]} \t${TEMP[1]} \t${TEMP[2]} \t${TEMP[3]} \t${TEMP[4]}"
		
#----hardware frequency and class temp -----
#cpuinfo freq
for i in {0..7}
do
  CPU0_FREQ[i]=$((`cat /sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_cur_freq`/1000))
done

#class temp
for i in {0..4}
do
  TEMP[i]=$((`cat /sys/class/thermal/thermal_zone$i/temp`/1000))
   if (( ${TEMP[i]} > 100000 )); then
   		kill $2
   fi
done

echo -e "$(date +'%s%N')  \t0 \t${CPU0_FREQ[0]} \t${CPU0_FREQ[1]} \t${CPU0_FREQ[2]} \t${CPU0_FREQ[3]} \t${CPU0_FREQ[4]} \t${CPU0_FREQ[5]} \t${CPU0_FREQ[6]} \t${CPU0_FREQ[7]} \t$GPU_FREQ  \t$CPU_GOVERNOR \t${TEMP[0]} \t${TEMP[1]} \t${TEMP[2]} \t${TEMP[3]} \t${TEMP[4]}"
					
sleep $1
done
