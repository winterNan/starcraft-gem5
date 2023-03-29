#!/usr/bin/bash

# run_ascylib.sh ---
#
# Filename: run_ascylib.sh
# Description:
# Author: yuan.yao@it.uu.se
# Maintainer:
# Created: Mon Mar 27 10:40:30 2023 (+0200)
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

ACTIOM=$1
PROGRAM=$2
CORE_NUM=$3

case $CORE_NUM in
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
    "32")
        ROW_NUM="8"
        ;;
    "64")
        ROW_NUM="8"
        ;;
esac

function func_get_func_name(){

    # Dear author of ASCYLIB:
    #        Thanks for your unique naming taste
    #        so that this big ugly function is needed.
    # Br,
    # A smily face

    case $1 in
        "bst-aravind")
            APP="lf-bst-aravind"
            ;;
        "bst-bronson")
            APP="lb-bst_bronson"
            ;;
        "bst-drachsler")
            APP="lb-bst-drachsler"
            ;;
        "bst-ellen")
            APP="lf-bst_ellen"
            ;;
        "bst-howley")
            APP="lf-bst-howley"
            ;;
        "bst-seq_external")
            APP="sq-bst_external"
            ;;
        "bst-seq_internal")
            APP="sq-bst_internal"
            ;;
        "bst-tk")
            APP="lb-bst_tk"
            ;;
        "hashtable-copy")
            APP="lb-ht_copy"
            ;;
        "hashtable-coupling")
            APP="lb-ht_coupling"
            ;;
        "hashtable-harris")
            APP="lf-ht_harris"
            ;;
        "hashtable-java")
            APP="lb-ht_java"
            ;;
        "hashtable-java_optik")
            APP="lb-ht_java_optik"
            ;;
        "hashtable-lazy")
            APP="lb-ht_lazy"
            ;;
        "hashtable-map_optik")
            APP="lb-ht_map"
            ;;
        "hashtable-optik0")
            APP="lb-ht_optik0"
            ;;
        "hashtable-optik1")
            APP="lb-ht_optik1"
            ;;
        "hashtable-pugh")
            APP="lb-ht_pugh"
            ;;
        "hashtable-rcu")
            APP="lf-ht_rcu"
            ;;
        "hashtable-seq")
            APP="sq-ht"
            ;;
        "hashtable-seq2")
            APP="sq-ht2"
            ;;
        "hashtable-tbb")
            APP="lb-ht_tbb"
            ;;
        "linkedlist-copy")
            APP="lb-ll_copy"
            ;;
        "linkedlist-coupling")
            APP="lb-ll_coupling"
            ;;
        "linkedlist-gl_opt")
            APP="lb-ll_gl"
            ;;
        "linkedlist-harris")
            APP="lf-ll_harris"
            ;;
        "linkedlist-harris_opt")
            APP="lf-ll_harris_opt"
            ;;
        "linkedlist-lazy")
            APP="lb-ll_lazy"
            ;;
        "linkedlist-lazy_cache")
            APP="lb-ll_lazy_cache"
            ;;
        "linkedlist-lazy_orig")
            APP="lb-ll_lazy_orig"
            ;;
        "linkedlist-lazy_sp")
            APP="lb-ll_lazy_sp"
            ;;
        "linkedlist-michael")
            APP="lf-ll_michael"
            ;;
        "linkedlist-optik")
            APP="lb-ll_optik"
            ;;
        "linkedlist-optik_cache")
            APP="lb-ll_optik_cache"
            ;;
        "linkedlist-optik_gl")
            APP="lb-ll_optik_gl"
            ;;
        "linkedlist-pugh")
            APP="lb-ll_pugh"
            ;;
        "linkedlist-seq")
            APP="sq-ll"
            ;;
        "map-lock")
            APP="lb-map"
            ;;
        "map-optik")
            APP="lb-map_optik"
            ;;
        "priorityqueue-alistarh-herlihyBased")
            APP="lf-pq_alistarh_herlihy"
            ;;
        "priorityqueue-alistarh-pughBased")
            APP="lb-pq_alistarh_pugh"
            ;;
        "priorityqueue-alistarh")
            APP="lf-pq_alistarh"
            ;;
        "priorityqueue-lotanshavit_lf")
            APP="lf-pq_lotanshavit"
            ;;
        "queue-hybrid")
            APP="lb-qu_hybrid"
            ;;
        "queue-ms_hybrid")
            APP="lb-qu_ms_hybrid"
            ;;
        "queue-ms_lb")
            APP="lb-qu_ms"
            ;;
        "queue-ms_lf")
            APP="lf-qu_ms"
            ;;
        "queue-optik0")
            APP="lb-qu_optik0"
            ;;
        "queue-optik1")
            APP="lb-qu_optik1"
            ;;
        "queue-optik2")
            APP="lb-qu_optik2"
            ;;
        "queue-optik2a")
            APP="lb-qu_optik2a"
            ;;
        "queue-optik3")
            APP="lb-qu_optik3"
            ;;
        "queue-optik4")
            APP="lb-qu_optik4"
            ;;
        "queue-optik5")
            APP="lb-qu_optik5"
            ;;
        "skiplist-fraser")
            APP="lf-sl_fraser"
            ;;
        "skiplist-herlihy_lb")
            APP="lb-sl_herlihy"
            ;;
        "skiplist-herlihy_lf")
            APP="lf-sl_herlihy"
            ;;
        "skiplist-optik")
            APP="lb-sl_optik"
            ;;
        "skiplist-optik1")
            APP="lb-sl_optik1"
            ;;
        "skiplist-optik2")
            APP="lb-sl_optik2"
            ;;
        "skiplist-pugh-string")
            APP="lb-sl_pugh_string"
            ;;
        "skiplist-pugh")
            APP="lb-sl_pugh"
            ;;
        "skiplist-seq")
            APP="sq-sl"
            ;;
        "stack-lock")
            APP="lb-st_lock"
            ;;
        "stack-optik")
            APP="lb-st_optik"
            ;;
        "stack-optik1")
            APP="lb-st_optik1"
            ;;
        "stack-optik2")
            APP="lb-st_optik2"
            ;;
        "stack-treiber")
            APP="lf-st_treiber"
            ;;
    esac
}

FULL_IMG_DIR="$HOME/full_system_images/disks/x86"
FULL_KERNEL_DIR="$HOME/full_system_images/binaries/x86"
ASCYLIB_INSTALL_DIR="$HOME/Benchmarks/ascylib/"
GEM5_INSTALL_DIR="$HOME/Capcom/capcom-gem5"
KERNEL_VER="x86_64-vmlinux-3.2.24-smp-capcom"
DISK_VER="linux-x86-ascylib-capcom.img"

COMMAND=(
    $GEM5_INSTALL_DIR/build/X86_MESI_Two_Level/gem5.fast \
        --outdir=$GEM5_INSTALL_DIR/script/x86/ascylib/$2/m5out/"${CORE_NUM}p" \
        --redirect-stdout \
        --redirect-stderr \
        $GEM5_INSTALL_DIR/configs/example/fs.py \
        --checkpoint-dir=$GEM5_INSTALL_DIR/script/x86/ascylib/$2/m5out/"${CORE_NUM}p" \
        --script=$GEM5_INSTALL_DIR/script/x86/ascylib/$2/"$2-${CORE_NUM}p".rcS \
        --ruby \
        --network=garnet \
        --caches \
        --l2cache \
        -n $CORE_NUM \
        --mem-size=3GB \
        --num-cpus=$CORE_NUM \
        --num-l2cache=$CORE_NUM \
        --num-dirs=$CORE_NUM \
        --topology=Mesh_XY \
        --mesh-rows=$ROW_NUM \
        --disk-image=$FULL_IMG_DIR/$DISK_VER \
        --kernel=$FULL_KERNEL_DIR/$KERNEL_VER
)

COMMAND_MK=(
    ${COMMAND[@]}
    --cpu-type=AtomicSimpleCPU
)

COMMAND_RE=(
    ${COMMAND[@]}
    --restore-with-cpu=TimingSimpleCPU \
    --standard-switch 1 \
    -r 1
)

COMMAND_ICELAKE=(
        $GEM5_INSTALL_DIR/build/X86_MESI_Two_Level/gem5.debug \
        --outdir=$GEM5_INSTALL_DIR/script/x86/ascylib/$2/m5out/"${CORE_NUM}p" \
        --redirect-stdout \
        --redirect-stderr \
        $GEM5_INSTALL_DIR/configs/example/fs.py \
        --checkpoint-dir=$GEM5_INSTALL_DIR/script/x86/ascylib/$2/m5out/"${CORE_NUM}p" \
        --script=$GEM5_INSTALL_DIR/script/x86/ascylib/$2/"$2-${CORE_NUM}p".rcS \
        --cpu-type=Icelake \ # ???
        --ruby \
        --caches \
        --l2cache \
        -n $CORE_NUM \
        --mem-size=4GB \
        --num-cpus=$CORE_NUM \
        --num-l2cache=$CORE_NUM \
        --num-dirs=$CORE_NUM \
        --network=garnet \
        --topology=Mesh_XY \
        --link-width-bits=512 \
        --mesh-rows=$ROW_NUM \
        --l0i_size=32kB \
        --l0d_size=48kB \
        --l0i_assoc=8 \
        --l0d_assoc=12 \
        --l1d_size=256kB \
        --l1d_assoc=8 \
        --num-l2caches=1 \
        --l2_size=16MB \
        --l2_assoc=16  \
        --sys-clock=2GHz \
        --cpu-clock=2GHz \
        --ruby-clock=2GHz \
        --mem-type=SimpleMemory \
        --mem-latency=80ns \
        --warmup-ticks=500 \
        --enable-prefetch \
        --enable-commit-prefetch=1
        --disk-image=$FULL_IMG_DIR/$DISK_VER \
        --kernel=$FULL_KERNEL_DIR/$KERNEL_VER
)

GDB_OPT=(
    "-iex set trace-commands on"
    "-iex set logging enabled on"
)

set -e

### To enable KVM ###
# sudo -S sh -c 'echo 1 >/proc/sys/kernel/perf_event_paranoid'

func_check_program_name(){
    if [[ " ${PROGRAM_SET[@]} " =~ " $PROGRAM " ]]; then
        ASCYLIB_APP_DIR="$ASCYLIB_INSTALL_DIR/bin"
    else
        echo -e "Program name ${RED}wrong${NC}."
        echo -e "Valid names:
                 ASCYLIB apps: ${GREEN}${PROGRAM_SET[@]}${NC}"
        echo -e "Now exit..."
        exit -1;
    fi
}

func_make_ckpt_ascylib() {

    func_check_program_name "$@";

    cd $ASCYLIB_INSTALL_DIR
    cd src/$2/
    make PC_NAME=gem5 GEM5_CORE_NUM=$CORE_NUM
    cd $ASCYLIB_INSTALL_DIR

    func_get_func_name $PROGRAM

    sudo -S mount -o loop,offset=32256 $FULL_IMG_DIR/$DISK_VER $FULL_IMG_DIR/linux_x86_mnt
    sudo cp $ASCYLIB_INSTALL_DIR/bin/gem5/${CORE_NUM}p/$APP $FULL_IMG_DIR/linux_x86_mnt/benchmarks/ascylib/install/bin.ckpts/${CORE_NUM}p
    sudo umount -l $FULL_IMG_DIR/$DISK_VER

    "${COMMAND_MK[@]}"
}

func_resume_ckpt_ascylib(){

    func_check_program_name "$@";

    "${COMMAND_RE[@]}"
}

func_run_gdb(){
    func_check_program_name "$@";

    gdb -q \
           -iex "set trace-commands on" \
           -iex "set logging on" \
           --args "${COMMAND[@]}" \
           # --args "${COMMAND[@]}"
}

func_launch_baremetal(){

    # Bring up a shell inside the simulated architecture
    # Do not redirect output

    $GEM5_INSTALL_DIR/build/X86/gem5.fast \
        --outdir=m5out_fs/baremetal \
        --redirect-stdout \
        --redirect-stderr \
        $GEM5_INSTALL_DIR/configs/example/fs.py \
        --checkpoint-dir=$GEM5_INSTALL_DIR/script/x86/ascylib/baremetal \
        --script=$GEM5_INSTALL_DIR/script/x86/ascylib/baremetal/test.rcS \
        --ruby \
        --network=garnet \
        --caches \
        --l2cache \
        -n $CORE_NUM  \
        --cpu-type=AtomicSimpleCPU \
        --mem-size=3GB \
        --num-cpus=$CORE_NUM \
        --num-l2cache=$CORE_NUM  \
        --num-dirs=$CORE_NUM  \
        --topology=Mesh_XY \
        --mesh-rows=$ROW_NUM  \
        --disk-image=$FULL_IMG_DIR/$DISK_VER \
        --kernel=$FULL_KERNEL_DIR/$KERNEL_VER
}

func_generate_rcs(){

    for i in "${PROGRAM_SET[@]}"; do
        for j in "${GRANULARITY_SET[@]}"; do
            func_get_func_name $i
            TEMPLATE="#!/bin/sh
#/sbin/m5 checkpoint
#echo \"Made checkpoint!\"
#/sbin/m5 exit
#/sbin/m5 exit

mount proc /proc -t proc
# Uncomment this if benchmarks loaded onto a separate disk.
# mount -t ext2 /dev/hdb1 /benchmarks

export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib64
export PATH=\$PATH:/usr/local/bin

echo \"Checking path settings: \"
echo \$LD_LIBRARY_PATH
echo \$PATH

# Switch on m5 pseudoinstructions called by instrumentation functions (SimRoiBegin, SimRoiEnd)
# in order to call m5_checkpoint, m5_exit, etc. (see benchmarks/libs/gem5/m5ops_wrapper.c)
export M5_SIMULATOR=1

pwd
cd /benchmarks/ascylib/install/bin.ckpts/${j}p
echo \"Begin benchmark!\"
/sbin/m5 dumpstats
/sbin/m5 resetstats

./${APP} -n $j -i 1024 #4048576
echo \":D\"
/sbin/m5 dumpstats
/sbin/m5 exit
/sbin/m5 exit"
            echo "$TEMPLATE" > $GEM5_INSTALL_DIR/script/x86/ascylib/$i/"$i-${j}p".rcS
        done
    done

}

main() {

    PROGRAM_SET=("bst-aravind" "bst-bronson" "bst-drachsler" "bst-ellen" "bst-howley" "bst-seq_external" "bst-seq_internal" "bst-tk"
                 "hashtable-copy"  "hashtable-coupling" "hashtable-harris" "hashtable-java" "hashtable-java_optik" "hashtable-lazy"
                 "hashtable-map_optik" "hashtable-optik0" "hashtable-optik1" "hashtable-pugh" "hashtable-rcu" "hashtable-seq" "hashtable-seq2"
                 "hashtable-tbb" "linkedlist-copy" "linkedlist-coupling" "linkedlist-gl_opt" "linkedlist-harris" "linkedlist-harris_opt"
                 "linkedlist-lazy" "linkedlist-lazy_cache" "linkedlist-lazy_orig" "linkedlist-lazy_sp" "linkedlist-michael" "linkedlist-optik"
                 "linkedlist-optik_cache" "linkedlist-optik_gl" "linkedlist-pugh" "linkedlist-seq" "map-lock" "map-optik"
                 "priorityqueue-alistarh-herlihyBased" "priorityqueue-alistarh-pughBased" "priorityqueue-alistarh" "priorityqueue-lotanshavit_lf"
                 "queue-hybrid" "queue-ms_hybrid" "queue-ms_lb" "queue-ms_lf" "queue-optik0" "queue-optik1" "queue-optik2" "queue-optik2a"
                 "queue-optik3" "queue-optik4" "queue-optik5" "skiplist-fraser" "skiplist-herlihy_lb" "skiplist-herlihy_lf" "skiplist-optik"
                 "skiplist-optik1"  "skiplist-optik2" "skiplist-pugh-string" "skiplist-pugh" "skiplist-seq" "stack-lock" "stack-optik"
                 "stack-optik1" "stack-optik2" "stack-treiber")

    GRANULARITY_SET=("2" "4" "8" "16" "32" "64")

    RED='\033[0;31m'
    NC='\033[0m'
    GREEN='\033[0;32m'

    if [[ " $1 " =~ " make_ckpt_ascylib " ]]; then
        func_make_ckpt_ascylib "$@";

    elif [[ " $1 " =~ " resume_ckpt_ascylib " ]]; then
        func_resume_ckpt_ascylib "$@";

    elif [[ " $1 " =~ " run_gdb " ]]; then
        func_run_gdb "$@";

    elif [[ " $1 " =~ " build_kernel " ]]; then
        cd $HOME/full_system_images/linux-3.2.24/
        bash compile-x86_64.sh

    elif [[ " $1 " =~ " launch_baremetal " ]]; then
        func_launch_baremetal "$@";

    elif [[ " $1 " =~ " generate_rcS " ]]; then
        func_generate_rcs;

    else
        echo -e "Action name ${RED}wrong${NC}."
        echo -e "Valid actions:
                1, ${GREEN}make_ckpt_ascylib${NC} + appname
                2, ${GREEN}resume_ckpt_ascylib${NC} + appname
                3, ${GREEN}run_gdb${NC} + appname
                4, ${GREEN}launch_baremetal${NC}
                5, ${GREEN}generate_rcS${NC}"
        echo -e "Now exit..."
        exit -2;
    fi
}

main "$@"; exit

#
# run_ascylib.sh ends here
