#!/bin/bash

# enable the sensors
echo 1 > /sys/bus/i2c/drivers/INA231/0-0045/enable
echo 1 > /sys/bus/i2c/drivers/INA231/0-0040/enable
echo 1 > /sys/bus/i2c/drivers/INA231/0-0041/enable
echo 1 > /sys/bus/i2c/drivers/INA231/0-0044/enable

# settle two seconds to the sensors get fully enabled and have the first reading
sleep 2

echo -e "timestamp \tVIRTUAL_SCALING \tCPU0_FREQ \tCPU1_FREQ \tCPU2_FREQ \tCPU3_FREQ \tCPU4_FREQ \tCPU5_FREQ \tCPU6_FREQ \tCPU7_FREQ \tGPU_FREQ \tCPU_GOVERNOR \tA15_V \tA15_A \tA15_W \tA7_V \tA7_A \tA7_W \tMEM_V \tMEM_A \tMEM_W \tGPU_V \tGPU_A \tGPU_W \tCPU0_TEMP \tCPU1_TEMP \tCPU2_TEMP \tCPU3_TEMP \tGPU_TEMP"

# Main infinite loop
while true; do

# CPU Governor
CPU_GOVERNOR=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

# A7 Nodes
A7_V=`cat /sys/bus/i2c/drivers/INA231/0-0045/sensor_V`
A7_A=`cat /sys/bus/i2c/drivers/INA231/0-0045/sensor_A`
A7_W=`cat /sys/bus/i2c/drivers/INA231/0-0045/sensor_W`

# A15 Nodes
A15_V=`cat /sys/bus/i2c/drivers/INA231/0-0040/sensor_V`
A15_A=`cat /sys/bus/i2c/drivers/INA231/0-0040/sensor_A`
A15_W=`cat /sys/bus/i2c/drivers/INA231/0-0040/sensor_W`

# --------- MEMORY DATA ----------- # 
MEM_V=`cat /sys/bus/i2c/drivers/INA231/0-0041/sensor_V`
MEM_A=`cat /sys/bus/i2c/drivers/INA231/0-0041/sensor_A`
MEM_W=`cat /sys/bus/i2c/drivers/INA231/0-0041/sensor_W`

# ---------- GPU DATA ------------- # 
GPU_V=`cat /sys/bus/i2c/drivers/INA231/0-0044/sensor_V`
GPU_A=`cat /sys/bus/i2c/drivers/INA231/0-0044/sensor_A`
GPU_W=`cat /sys/bus/i2c/drivers/INA231/0-0044/sensor_W`

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
done

GPU_FREQ=$((`cat /sys/bus/platform/drivers/mali/11800000.mali/devfreq/devfreq0/cur_freq`/1000000))

echo -e "$(date +'%s%N') \t1 \t${CPU0_FREQ[0]} \t${CPU0_FREQ[1]} \t${CPU0_FREQ[2]} \t${CPU0_FREQ[3]} \t${CPU0_FREQ[4]} \t${CPU0_FREQ[5]} \t${CPU0_FREQ[6]} \t${CPU0_FREQ[7]} \t$GPU_FREQ \t$CPU_GOVERNOR \t$A15_V \t$A15_A \t$A15_W \t$A7_V \t$A7_A \t$A7_W \t$MEM_V \t$MEM_A \t$MEM_W \t$GPU_V \t$GPU_A \t$GPU_W \t${TEMP[0]} \t${TEMP[1]} \t${TEMP[2]} \t${TEMP[3]} \t${TEMP[4]}"
		
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
done

echo -e "$(date +'%s%N')  \t0 \t${CPU0_FREQ[0]} \t${CPU0_FREQ[1]} \t${CPU0_FREQ[2]} \t${CPU0_FREQ[3]} \t${CPU0_FREQ[4]} \t${CPU0_FREQ[5]} \t${CPU0_FREQ[6]} \t${CPU0_FREQ[7]} \t$GPU_FREQ  \t$CPU_GOVERNOR \t$A15_V \t$A15_A \t$A15_W \t$A7_V \t$A7_A \t$A7_W \t$MEM_V \t$MEM_A \t$MEM_W \t$GPU_V \t$GPU_A \t$GPU_W \t${TEMP[0]} \t${TEMP[1]} \t${TEMP[2]} \t${TEMP[3]} \t${TEMP[4]}"
					
sleep $1
done
