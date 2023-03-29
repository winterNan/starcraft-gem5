#!/bin/bash

target_benchmarks=(
    "blackscholes"
    "bodytrack" # need multithreading
    # "facesim"   # too large
    # "ferret"
    # "fluidanimate"
    # "freqmine"  # need multithreading
    # "raytrace"
    # "swaptions"
    # "vips"      # need syscall sched_getparam
    # "x264"      # dont use too large input
    # "canneal"
    # "dedup"
    # "streamcluster"
)

for CORE_NUM in 2 4
do
    for i in "${target_benchmarks[@]}"
    do 
        EXTRA_FLAG=""
        if [ "$CORE_NUM" == "64" ] || [ "$CORE_NUM" == "32" ]; then
               EXTRA_FLAG="-n 3"
        fi
        case $i in
            "blackscholes")
                ;;
            "bodytrack")
                EXTRA_FLAG="-n 4"
                ;;
            "facesim")
                ;;
            "ferret")
                EXTRA_FLAG="-n 4"
                ;;
            "fluidanimate")
                ;;
            "freqmine")
                ;;
            "raytrace")
                ;;
            "swaptions")
                ;;
            "vips")
                if [ "$CORE_NUM" == "64" ] || [ "$CORE_NUM" == "30" ]; then
                       EXTRA_FLAG="-n 6"
                fi
                ;;
            "x264")
                ;;
            "canneal")
                ;;
            "dedup")
                if [ "$CORE_NUM" == "64" ] || [ "$CORE_NUM" == "32" ]; then
                       EXTRA_FLAG="-n 8"
                fi
                ;;
            "streamcluster")
                ;;
            *)
                echo "Incorrect benchmark name!"
                exit 1
                ;;
        esac


        echo "Starting job: ${i} with ${CORE_NUM} cores"
        COMMAND=(
            sbatch 
            -o 
            slurm-%j_inputsim_${i}_${CORE_NUM}.out 
            ${EXTRA_FLAG}
            run_one.sh
            ${i} 
            ${CORE_NUM} 
        )
        "${COMMAND[@]}" 
    done
done
