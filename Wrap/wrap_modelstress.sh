#!/bin/bash

echo "START"
date
PATH_CPUBOUND=/home/demetrios/Projects/XU3EM/ODROID_XU3/cpu_bound
PATH_RESULTS=../Results

methods="ackermann bitops callfunc cdouble cfloat clongdouble correlate crc16 dither djb2a double euler explog fft factorial fibonacci float float32 fnv1a gamma gcd gray hamming hanoi hyperbolic idct int64 int32 int16 int8 int64float int64double int64longdouble int32float int32double int32longdouble jenkin jmp ln2 longdouble loop matrixprod nsqrt omega parity phi pi pjw prime psi queens rand rand48 rgb sdbm sieve stats sqrt trig union zeta"
IFS=' ' read -r -a m_array <<< "$methods"
for m in "${m_array[@]}"
do
  echo "METHOD $m"
  echo "$m" > "$PATH_CPUBOUND/method.temp"
  ./MC_XU3_PARETO.sh -b 2 -L 4 -f 1900000 -q 1500000 -n 1 -x $PATH_CPUBOUND/model_stress.sh -t 500000000 -s $PATH_RESULTS/stress_test/$m/
done
echo "END"
date
