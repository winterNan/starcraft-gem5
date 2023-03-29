#!/bin/bash
#
# Author: Yuan Yao
#         yuan.yao@it.uu.se
#
# Research group UART, Uppsala University
#
# The script automatically uses KVM to fast forward
# a benchmark to the begining of ROI, then checkpoints
# the execution. It can also resume later from the checkpoint 
# using the resumt_ckpt command.
#
# Supported benchmarks: PARSEC-3.0

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
esac

FULL_IMG_DIR="$HOME/full_system_images/disks/x86"
FULL_KERNEL_DIR="$HOME/full_system_images/binaries/x86"
PARSEC_INSTALL_DIR="$HOME/Benchmarks/parsec/parsec-3.0"
GEM5_INSTALL_DIR="$HOME/Capcom/capcom-gem5"
DISK_VER="linux-x86-parsec-capcom.img"
KERNEL_VER="x86_64-vmlinux-3.2.24-smp-capcom"

set -e

### To enable KVM ###

sudo sh -c 'echo 1 >/proc/sys/kernel/perf_event_paranoid'

func_make_ckpt_parsec() {

    func_check_program_name "$@";

    # Analyze packet dependencies
    # Recompile each of the dependent lib

    cd $PARSEC_INSTALL_DIR
    source env.sh

    if [ ! -f "${PKGPARSECDIR}/gcc-hooks.bldconf" ]; then
        echo "${oprefix} Error: Cannot find local build configuration '${build}.bldconf' for package ${pkg}." 2>&1 | ${TEE} ${log}
        exit 1
    else
        dependency=$(grep 'build_deps' ${PKGPARSECDIR}/gcc-hooks.bldconf | cut -d\= -f2)
        dependency="${dependency//\"}"
    fi

    IFS=' ' read -r -a dep_array <<< "$dependency"

    echo -e "Program $2 depends on library ${GREEN} ${dep_array[@]} ${NC}"

    for var in "${dep_array[@]}"
    do
        echo -e "${GREEN} Now build ${var} ${NC}"
        parsecmgmt -a fulluninstall -c gcc-hooks -p $var
        parsecmgmt -a fullclean -c gcc-hooks -p $var
        parsecmgmt -a build -c gcc-hooks -p $var
    done

    parsecmgmt -a fulluninstall -c gcc-hooks -p $2
    parsecmgmt -a fullclean -c gcc-hooks -p $2
    parsecmgmt -a build -c gcc-hooks -p $2

    if  [[ " $2 " =~ " vips " ]]; then
        cd $PARSEC_INSTALL_DIR
        ./vips.static_link.sh
    fi

    sudo -S mount -o loop,offset=32256 $FULL_IMG_DIR/linux-x86.img $FULL_IMG_DIR/linux_x86_mnt
    cp $PARSEC_APP_DIR $FULL_IMG_DIR/linux_x86_mnt/benchmarks/parsec/install/bin.ckpts/
    sudo umount $FULL_IMG_DIR/linux-x86.img

    $GEM5_INSTALL_DIR/build/X86_MESI_Two_Level/gem5.fast \
    --outdir=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$2/m5out/"${CORE_NUM}p" \
    --redirect-stdout \
    --redirect-stderr \
    $GEM5_INSTALL_DIR/configs/example/fs.py \
    --checkpoint-dir=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$2/m5out/"${CORE_NUM}p" \
    --script=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$2/"$2-${CORE_NUM}p".rcS \
    --cpu-type=AtomicSimpleCPU \
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
    --kernel=$FULL_KERNEL_DIR/$KERNEL_VER &
}

func_resume_ckpt_parsec(){

    func_check_program_name "$@";

    $GEM5_INSTALL_DIR/build/X86_MESI_Two_Level/gem5.fast \
    --outdir=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$2/m5out/"${CORE_NUM}p" \
    --redirect-stdout \
    --redirect-stderr \
    $GEM5_INSTALL_DIR/configs/example/fs.py \
    --checkpoint-dir=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$2/m5out/"${CORE_NUM}p" \
    --script=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$2/"$2-${CORE_NUM}p".rcS \
    --restore-with-cpu=TimingSimpleCPU \
        --ruby \
    --standard-switch 1 \
    -r 1 \
        --network=garnet \
    --caches \
    --l2cache \
    -n $CORE_NUM \
    --mem-size=3GB \
    --num-cpus=$CORE_NUM \
    --num-l2cache=$CORE_NUM  \
    --num-dirs=$CORE_NUM  \
    --topology=Mesh_XY \
    --mesh-rows=$ROW_NUM  \
    --disk-image=$FULL_IMG_DIR/$DISK_VER \
    --kernel=$FULL_KERNEL_DIR/$KERNEL_VER
}

func_check_program_name(){
    if [[ " ${PROGRAM_SET[@]} " =~ " $PROGRAM " ]]; then
        PARSEC_APP_DIR="$PARSEC_INSTALL_DIR/pkgs/apps/$PROGRAM/inst/amd64-linux.gcc-hooks/bin/$PROGRAM"
        PKGPARSECDIR=${PARSEC_INSTALL_DIR}/pkgs/apps/$PROGRAM/parsec

    elif [[ " ${KERNEL_SET[@]} " =~ " $PROGRAM " ]]; then
        PARSEC_APP_DIR="$PARSEC_INSTALL_DIR/pkgs/kernels/$PROGRAM/inst/amd64-linux.gcc-hooks/bin/$PROGRAM"
        PKGPARSECDIR=${PARSEC_INSTALL_DIR}/pkgs/kernels/$PROGRAM/parsec

    else
        echo -e "Program name ${RED}wrong${NC}."
        echo -e "Valid names:
                PARSEC-3.0 apps: ${PROGRAM_SET[@]},
                PARSEC-3.0 kernels: ${KERNEL_SET[@]}."
        echo -e "Now exit..."
        exit -1;
    fi
}

func_check_build(){
    if [[ " $2 " =~ " all " ]]; then

        for i in "${PROGRAM_SET[@]}"
        do
            PARSEC_APP_DIR="$PARSEC_INSTALL_DIR/pkgs/apps/$i/inst/amd64-linux.gcc-hooks/bin/$i"
            info=`file $PARSEC_APP_DIR`
            if [[ $info == *"statically"* ]]; then
                echo -e ${GREEN}$info
            elif [[ $info == *"dynamically"* ]]; then
                echo -e ${RED}$info
            else
                echo -e "${RED}Error${NC} while reading file type of $PARSEC_APP_DIR"
            fi
        done

        for i in "${KERNEL_SET[@]}"
        do
            PARSEC_APP_DIR="$PARSEC_INSTALL_DIR/pkgs/kernels/$i/inst/amd64-linux.gcc-hooks/bin/$i"
            info=`file $PARSEC_APP_DIR`
            if [[ $info == *"statically"* ]]; then
                echo -e ${GREEN}$info
            elif [[ $info == *"dynamically"* ]]; then
                echo -e ${RED}$info
            else
                echo -e "${RED}Error${NC} while reading file type of $PARSEC_APP_DIR"
            fi
        done

        return
    else
        func_check_program_name "$@";

        info=`file $PARSEC_APP_DIR`
        if [[ $info == *"statically"* ]]; then
            echo -e ${GREEN}$info
        elif [[ $info == *"dynamically"* ]]; then
            echo -e ${RED}$info
        else
            echo -e "${RED}Error${NC} while reading file type of $PARSEC_APP_DIR"
        fi
    fi
}

func_launch_baremetal(){

    # Bring up a shell inside the simulated architecture
    # Do not redirect output

    $GEM5_INSTALL_DIR/build/X86_MESI_Two_Level/gem5.fast \
    --outdir=$GEM5_INSTALL_DIR/script/x86/zz_launch_parsec/m5out \
    --redirect-stdout \
    --redirect-stderr \
    $GEM5_INSTALL_DIR/configs/example/fs.py \
    --checkpoint-dir=$GEM5_INSTALL_DIR/script/x86/zz_launch_parsec/m5out \
    --script=$GEM5_INSTALL_DIR/script/x86/zz_launch_parsec/test.rcS \
    --cpu-type=AtomicSimpleCPU \
        --ruby \
    --network=garnet \
    --caches \
    --l2cache \
    -n $CORE_NUM  \
    --mem-size=3GB \
    --num-cpus=$CORE_NUM \
    --num-l2cache=$CORE_NUM  \
    --num-dirs=$CORE_NUM  \
    --topology=Mesh_XY \
    --mesh-rows=$ROW_NUM  \
    --disk-image=$FULL_IMG_DIR/$DISK_VER \
    --kernel=$FULL_KERNEL_DIR/$KERNEL_VER
}

main() {

    PROGRAM_SET=("blackscholes" "bodytrack" "facesim" "ferret" "fluidanimate" "freqmine" "raytrace" "swaptions" "vips" "x264")
    KERNEL_SET=("canneal" "dedup" "streamcluster")

    RED='\033[0;31m'
    NC='\033[0m'
    GREEN='\033[0;32m'

    if [[ " $1 " =~ " make_ckpt_parsec " ]]; then
        func_make_ckpt_parsec "$@";

    elif [[ " $1 " =~ " resume_ckpt_parsec " ]]; then
        func_resume_ckpt_parsec "$@";

    elif [[ " $1 " =~ " check_build " ]]; then
        func_check_build "$@";

    elif [[ " $1 " =~ " build_kernel " ]]; then
        cd $HOME/full_system_images/linux-3.2.24/
        bash compile-x86_64.sh

    elif [[ " $1 " =~ " launch_baremetal " ]]; then
        func_launch_baremetal "$@";

    else
        echo -e "Action name ${RED}wrong${NC}."
        echo -e "Valid actions:
                1, ${GREEN}make_ckpt_parsec${NC} + appname
                2, ${GREEN}resume_ckpt_parsec${NC} + appname
                4, ${GREEN}check_build${NC} + appname/all
                5, ${GREEN}build_kernel${NC}
                6, ${GREEN}launch_baremetal${NC}"
        echo -e "Now exit..."
        exit -2;
    fi
}

main "$@"; exit
