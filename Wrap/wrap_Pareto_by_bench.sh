#!/bin/bash

export OMP_PLACES="{4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7}"
#export OMP_NUM_THREADS=8 #freqmine

echo "****blackscholes****"
echo "OMP_PLACES $OMP_PLACES"

echo "running temp/freq"
./check_temp.sh 5 > "temp_blackscholes.data" &
PID_check_temp=$!
disown

echo "running check aff"
./check_aff.sh blackscholes 5 > "aff_blackscholes.data" &
PID_check_aff=$!
disown

./wrap_Pareto.sh frequencies_temp.data blackscholes

echo "Kill"
kill $PID_check_temp > /dev/null
kill $PID_check_aff > /dev/null

echo "****Bodytrack****"
echo "OMP_PLACES $OMP_PLACES"

echo "running temp/freq"
./check_temp.sh 5 > "temp_Bodytrack.data" &
PID_check_temp=$!
disown

echo "running check aff"
./check_aff.sh bodytrack 5 > "aff_Bodytrack.data" &
PID_check_aff=$!
disown

./wrap_Pareto.sh frequencies_temp.data bodytrack

echo "Kill"
kill $PID_check_temp > /dev/null
kill $PID_check_aff > /dev/null

echo "****freqmine****"

echo "running temp/freq"
./check_temp.sh 5 > "temp_freqmine.data" &
PID_check_temp=$!
disown

echo "running check aff"
./check_aff.sh freqmine 5 > "aff_freqmine.data" &
PID_check_aff=$!
disown

echo "OMP_PLACES $OMP_PLACES"
./wrap_Pareto.sh frequencies_temp.data freqmine

echo "Kill"
kill $PID_check_temp > /dev/null
kill $PID_check_aff > /dev/null

