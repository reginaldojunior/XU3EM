#!/bin/bash

echo "START"
date

#export OMP_PROC_BIND=true
export OMP_PLACES="{4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7},{0,1,2,3,4,5,6,7}"
#export OMP_NUM_THREADS=8 #freqmine


#echo "TEST"
#date
#./MC_XU3_PARETO.sh -b 1 -L 1 -f 700000,700000,800000 -q 400000,600000,400000 -n 1 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/blacktest_1_1_/noevents/

#file_body="/home/demetrios/Projects/XU3EM/ODROID_XU3/frequencies_notincluded_body.data"
file_black="/home/demetrios/Projects/XU3EM/ODROID_XU3/frequencies_freqmine_pareto_rel.data"
'''
while read line
do
    b=$line
    read line
	L=$line
	read line
	fb_body=$line
	read line
	fL_body=$line

    echo "$b $L"
    echo "$fb_body"
    echo "$fL_body"

done < "$file_body"
'''

while read line
do
    b=$line
    read line
    L=$line
    read line
    fb_black=$line
    read line
    fL_black=$line

    echo "$b $L"
    echo "$fb_black"
    echo "$fL_black"

done < "$file_black"

'''
IFS=',' read -r -a array_fb_black <<< "$fb_black"
IFS=',' read -r -a array_fL_black <<< "$fL_black"
IFS=',' read -r -a array_fb_body <<< "$fb_body"
IFS=',' read -r -a array_fL_body <<< "$fL_body"

for i in $(seq 0 4);
do  
    
    start=$(echo "$i*5" | bc )
    end=$(echo "($i+1)*5-1" | bc )

    fb_black_part=${array_fb_black[$start]}
    fL_black_part=${array_fL_black[$start]}
    fb_body_part=${array_fb_body[$start]}
    fL_body_part=${array_fL_body[$start]}

    for j in $(seq $(echo "$start+1" | bc ) "$end");
    do  
        fb_black_part="$fb_black_part,${array_fb_black[$j]}"
        fL_black_part="$fL_black_part,${array_fL_black[$j]}"
        fb_body_part="$fb_body_part,${array_fb_body[$j]}"
        fL_body_part="$fL_body_part,${array_fL_body[$j]}"   
    done

    echo "PART $i"
'''
	bench[0]="freqmine"
    #bench[0]="blackscholes"
    #bench[1]="bodytrack"
    for k in `echo ${!bench[*]}`;do

        echo "bench - ${bench[$i]}"

        echo "OMP_PLACES2 $OMP_PLACES"

        parsec_app=parsec.${bench[$k]}

        PATH_PARSEC=../Workloads/parsec-3.0
        PATH_RESULTS=../Results

        sed -i "/#/! s/^/#/" $PATH_PARSEC/bench_list.data #MAKE SURE EACH LINE HAS # character

        cat $PATH_PARSEC/bench_list.data

        echo ' '

        sed -i "/$parsec_app/   s/.//" $PATH_PARSEC/bench_list.data  #editing the bench_list.data to run the specific parsec application

        cat $PATH_PARSEC/bench_list.data

        echo ' '

        echo "START"

            echo "running check aff"
            ./check_aff.sh freqmine 3 > "aff_freqmine.data" &
            PID_check_aff=$!
            disown

            ./MC_XU3_PARETO.sh -b $b -L $L -f $fb_black -q $fL_black -n 2 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/pareto_validation/${bench[$k]}_${b}_${L}/

            echo "Kill"
            kill $PID_check_aff > /dev/null

'''
        if [ "${bench[$k]}" = "blackscholes" ]
        then

            echo "running check aff"
            ./check_aff.sh blackscholes 5 > "aff_blackscholes.data" &
            PID_check_aff=$!
            disown

            ./MC_XU3_PARETO.sh -b $b -L $L -f $fb_black -q $fL_black -n 5 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/pareto_validation_notincluded/${bench[$k]}_${b}_${L}/
            
            echo "Kill"
            kill $PID_check_aff > /dev/null            
        else
            echo "running check aff"
            ./check_aff.sh bodytrack 5 > "aff_bodytrack.data" &
            PID_check_aff=$!
            disown

            ./MC_XU3_PARETO.sh -b $b -L $L -f $fb_body -q $fL_body -n 5 -x $PATH_PARSEC/parsec_alone.sh -t 500000000 -s $PATH_RESULTS/pareto_validation_notincluded/${bench[$k]}_${b}_${L}/

            echo "Kill"
            kill $PID_check_aff > /dev/null             
        fi
'''
        sed -i "/$parsec_app/   s/^/#/" $PATH_PARSEC/bench_list.data #Add the # character

        cat $PATH_PARSEC/bench_list.data

        echo "END"
        date
    done

#done





