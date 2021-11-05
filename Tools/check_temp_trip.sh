#!/bin/bash

echo -e "trip_point_temp \tvirtual \tThermal_zone0 \tThermal_zone1 \tThermal_zone2 \tThermal_zone3"

# Main infinite loop
while true; do
for j in {0..6}
do
   for i in {0..3}   
   do
      VTRIP[i,j]=$((`cat /sys/devices/virtual/thermal/thermal_zone$i/trip_point_$j\_temp`/1000))
      CTRIP[i,j]=$((`cat /sys/class/thermal/thermal_zone$i/trip_point_$j\_temp`/1000))
   done
done


for j in {0..6}
do
   #virtual
   printf "%s \t%s" $j 1
   for i in {0..3}
   do     
      printf "\t%s" ${VTRIP[i,j]}
   done
   printf "\n"
   #class
   printf "%s \t%s" $j 0
   for i in {0..3}
   do     
      printf "\t%s" ${CTRIP[i,j]}
   done  
   printf "\n" 
done
sleep $1
done

