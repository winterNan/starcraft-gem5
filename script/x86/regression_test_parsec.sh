#!/bin/bash

# regression_test_parsec.sh ---
#
# Filename: regression_test.sh
# Description:
# Author: yuan.yao@it.uu.se
# Maintainer:
# Created: Mon Mar 27 11:11:38 2023 (+0200)
# Version:
# Package-Requires: ()
# Last-Updated:
#           By:
#     Update #: 0
# URL:
# Doc URL:
# Keywords:
# Compatibility:
#
#

# Commentary:
#
#
#  ________________________________________
# / There are two ways to write error-free \
# \ programs; only the third one works.    /
#  ----------------------------------------
#    \
#     \
#         .--.
#        |o_o |
#        |:_/ |
#       //   \ \
#      (|     | )
#     /'\_   _/`\
#     \___)=(___/
#
#

# Change Log:
#
#
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.
#
#

# Code:

GEM5_INSTALL_DIR="/home/yuan/Capcom/capcom-gem5"
IMAGE_INSTALL_DIR="/home/yuan/full_system_images"
KERNEL_VER="x86_64-vmlinux-3.2.24-smp-capcom"
DISK_VER="linux-x86-parsec-capcom.img"
CKPT_INSTALL_DIR="/home/yuan/Capcom/capcom-gem5"

PROGRAM=(
    "blackscholes"
    "bodytrack"
    "canneal"
    "dedup"
    "facesim"
    "fluidanimate"
    "ferret"
    "freqmine"
    "streamcluster"
    "swaptions"
    "vips"
    "x264"
)

SIZE=(
    "2"
    "4"
    "8"
    "16"
    "32"
    "64"
)

func_launch_test() {
    for i in "${PROGRAM[@]}"; do
        for j in "${SIZE[@]}"; do

            rm $GEM5_INSTALL_DIR/script/x86/parsec-3.0/$i/m5out/"${j}p"/simerr
            rm $GEM5_INSTALL_DIR/script/x86/parsec-3.0/$i/m5out/"${j}p"/simout

            case $j in
                "1")
                    ROW_NUM="1"
                    ;;
                "2")
                    ROW_NUM="2"
                    ;;
                "4")
                    ROW_NUM="2"
                    ;;
                "8")
                    ROW_NUM="4"
                    ;;
                "16")
                    ROW_NUM="4"
                    ;;
            esac

            case $i in
                "blackscholes")
                    TBEs=256
                    ;;
                "bodytrack")
                    TBEs=256
                    ;;
                "canneal")
                    TBEs=65536
                    ;;
                "dedup")
                    TBEs=256
                    ;;
                "facesim")
                    TBEs=256
                    ;;
                "fluidanimate")
                    TBEs=256
                    ;;
                "ferret")
                    TBEs=256
                    ;;
                "freqmine")
                    TBEs=256
                    ;;
                "streamcluster")
                    TBEs=256
                    ;;
                "swaptions")
                    TBEs=256
                    ;;
                "vips")
                    TBEs=256
                    ;;
                "x264")
                    TBEs=256
                    ;;
            esac


            $GEM5_INSTALL_DIR/build/X86_MESI_Two_Level/gem5.fast \
                --outdir=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$i/m5out/"${j}p" \
                --redirect-stdout \
                --redirect-stderr \
                $GEM5_INSTALL_DIR/configs/example/fs.py \
                --checkpoint-dir=$CKPT_INSTALL_DIR/script/x86/parsec-3.0/$i/m5out/"${j}p" \
                --script=$CKPT_INSTALL_DIR/script/x86/parsec-3.0/$i/"$i-${j}p".rcS \
                --restore-with-cpu=TimingSimpleCPU \
                --ruby \
                --standard-switch 1 \
                -r 1 \
                --network=garnet \
                --caches \
                --l2cache \
                -n $j \
                --mem-size=3GB \
                --num-cpus=$j \
                --num-l2cache=$j \
                --num-dirs=$j \
                --topology=Mesh_XY \
                --mesh-rows=$ROW_NUM \
                --disk-image=$IMAGE_INSTALL_DIR/disks/x86/$DISK_VER \
                --kernel=$IMAGE_INSTALL_DIR/binaries/x86/$KERNEL_VER
        done
    done
}

func_check_status() {
    for i in "${PROGRAM[@]}"; do
        for j in "${SIZE[@]}"; do
            input=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$i/m5out/"${j}p"/simerr
            INFO=""

            while IFS= read -r line
            do
                if [[ "$line" == *"panic: Invalid transition"* ]]; then
                    INFO="-/IV/-----"
                    break
                elif [[ "$line" == *"panic: Possible Deadlock detected"* ]]; then
                    INFO="-/DEAD/---"
                    break
                elif [[  "$line" == *"Assertion"* ]]; then
                    INFO="-/ASS/----"
                    break
                elif [[ "$line" == *"--- BEGIN LIBC BACKTRACE ---"* ]]; then
                    INFO="-/OTHER/--"
                    break
                elif [[ "$line" == *"fatal"* ]]; then
                    INFO="-/OTHER/--"
                    break
                elif [[ "$line" == *"segmentation fault"* ]]; then
                    INFO="-/SF!/----"
                    break
                elif [[ "$line" == "Exiting"* ]]; then
                    INFO="-*FIN*----"
                    break
                else
                    continue
                fi
            done < "$input"

            case $i in
                "blackscholes")
                    ROW=46
                    ;;
                "bodytrack")
                    ROW=49
                    ;;
                "canneal")
                    ROW=52
                    ;;
                "dedup")
                    ROW=55
                    ;;
                "facesim")
                    ROW=58
                    ;;
                "fluidanimate")
                    ROW=61
                    ;;
                "ferret")
                    ROW=64
                    ;;
                "freqmine")
                    ROW=67
                    ;;
                "streamcluster")
                    ROW=70
                    ;;
                "swaptions")
                    ROW=73
                    ;;
                "vips")
                    ROW=76
                    ;;
                "x264")
                    ROW=79
                    ;;
            esac

            case $j in
                "2")
                    COL=4
                    ;;
                "4")
                    COL=5
                    ;;
                "8")
                    COL=6
                    ;;
                "16")
                    COL=7
                    ;;
                "32")
                    COL=8
                    ;;
                "64")
                    COL=9
                    ;;
            esac

            if [[ -z "$INFO" ]]; then
                input=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$i/m5out/"${j}p"/simout
                INFO="-_TEST_---"
                while IFS= read -r line
                do
                    if [[ "$line" == *"Exiting @ tick"* ]]; then
                        INFO="-*FIN*----"
                        break
                    else
                        continue
                    fi
                done < "$input"
            fi

            output=$GEM5_INSTALL_DIR/README
            awk -F '|' -v row=$ROW -v col=$COL -v info=$INFO '{OFS = FS} FNR==row{$col=info}1' \
                $output > $GEM5_INSTALL_DIR/tmp && mv $GEM5_INSTALL_DIR/tmp $output
        done
    done
}

main() {

    if [[ " $1 " =~ " launch_test " ]]; then
        func_launch_test "$@";
    elif [[ " $1 " =~ " check_status " ]]; then
        func_check_status "$@";
    fi
}

main "$@"; exit

#
# regression_test.sh ends here
