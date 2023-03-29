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
# Supported benchmarks: WHISPER

ACTIOM=$1
PROGRAM=$2
CORE_NUM=$3

FULL_IMG_DIR="$HOME/full_system_images/disks/x86"
FULL_KERNEL_DIR="$HOME/full_system_images/binaries/x86"
WHISPER_INSTALL_DIR="$HOME/Benchmarks/whisper"
GEM5_INSTALL_DIR="$HOME/Capcom/capcom-gem5"
DISK_VER="linux-x86-whisper-capcom.img"
KERNEL_VER="x86_64-vmlinux-3.2.24-smp-capcom"

### Stop on any error ###

set -e

### To enable KVM ###

sudo sh -c 'echo 1 >/proc/sys/kernel/perf_event_paranoid'

export PATH=$HOME/scons-2.1.0/bin:$PATH

# setup cmake to cmake-3.20.2. The default version won't do

export PATH=$HOME/cmake-3.20.2/bin:$PATH

# setup pkg-config PATH for Intel libfabric, which is locally installed in the home dir.

export PKG_CONFIG_PATH=$HOME/libfabric-1.12.1/lib/pkgconfig:$PKG_CONFIG_PATH
export CPATH=$HOME/libfabric-1.12.1/include:$CPATH

func_build_whisper() {

	func_check_program_name "$@"

	cd $WHISPER_INSTALL_DIR

	if [[ " $2 " =~ " memcached " ]]; then
		pwd
		./build-memcached.sh

	elif [[ " $2 " =~ " vacation " ]]; then
		./build-vacation.sh

	else
		./script.py -c -s -w $2
		./script.py -b -w $2
	fi

	sudo -S mount -o loop,offset=32256 $FULL_IMG_DIR/linux-x86.img $FULL_IMG_DIR/linux_x86_mnt
	cp $WHISPER_APP_DIR $FULL_IMG_DIR/linux_x86_mnt/benchmarks/whisper/install/bin/

	if [[ " $2 " =~ " memcached " ]]; then
		cp $PATH_TO_MEMSLAP $FULL_IMG_DIR/linux_x86_mnt/benchmarks/whisper/install/bin/
	fi

	if [[ " $2 " =~ " redis " ]]; then
		cp $PATH_TO_REDIS_CLIENT $FULL_IMG_DIR/linux_x86_mnt/benchmarks/whisper/install/bin/
	fi

	sudo umount $FULL_IMG_DIR/linux-x86.img

	$GEM5_INSTALL_DIR/build/X86_MESI_Two_Level/gem5.fast \
	--outdir=$GEM5_INSTALL_DIR/script/x86/whisper/$2/m5out \
	--redirect-stdout \
	--redirect-stderr \
	$GEM5_INSTALL_DIR/configs/example/fs.py \
	--checkpoint-dir=$GEM5_INSTALL_DIR/script/x86/whisper/$2/m5out \
	--script=$GEM5_INSTALL_DIR/script/x86/whisper/$2/$2.rcS \
	--cpu-type=X86KvmCPU \
	--ruby \
	--caches \
	--l2cache \
	-n 1 \
	--mem-size=16GB \
	--num-cpus=$CORE_NUM \
	--num-l2cache=$CORE_NUM \
	--num-dirs=$CORE_NUM \
	--topology=Mesh_XY \
	--mesh-rows=$CORE_NUM \
	--disk-image=$FULL_IMG_DIR/$DISK_VER \
	--kernel=$FULL_KERNEL_DIR/$KERNEL_VER
}

func_check_program_name(){

	case $2 in

		("ycsb" | "tpcc")
		WHISPER_APP_DIR=$PATH_TO_NSTORE
		;;

		("echo")
		WHISPER_APP_DIR=$PATH_TO_ECHO
		;;

		("memcached")
		WHISPER_APP_DIR=$PATH_TO_MEMCACHED
		;;

		("vacation")
		WHISPER_APP_DIR=$PATH_TO_VACATION
		;;

		("ctree" | "hashmap")
		WHISPER_APP_DIR=$PATH_TO_PMEMBEMCH
		;;

		("redis")
		WHISPER_APP_DIR=$PATH_TO_REDIS_SERVER
		;;

		(*)

		echo -e "Program name ${RED}wrong${NC}."
		echo -e "Valid names:
		WHISPER apps: ${PROGRAM_SET[@]}"
		echo -e "Now exit..."
		exit -1;

	esac

}

func_check_build(){
	if [[ " $2 " =~ " all " ]]; then

		PROGRAM_SET=($PATH_TO_NSTORE
			         $PATH_TO_ECHO
			         $PATH_TO_MEMCACHED
			         $PATH_TO_MEMSLAP
			         $PATH_TO_VACATION
			         $PATH_TO_PMEMBEMCH
			         $PATH_TO_REDIS_SERVER
			         $PATH_TO_REDIS_CLIENT)

		for i in "${PROGRAM_SET[@]}"
		do
			WHISPER_APP_DIR=$i
			info=`file $WHISPER_APP_DIR`
			if [[ $info == *"statically"* ]]; then
				echo -e ${GREEN}$info
			elif [[ $info == *"dynamically"* ]]; then
				echo -e ${RED}$info
			else
				echo -e "${RED}Error${NC} while reading file type of $WHISPER_APP_DIR"
			fi
		done

		return
	else
		func_check_program_name "$@";

		info=`file $WHISPER_APP_DIR`
		if [[ $info == *"statically"* ]]; then
			echo -e ${GREEN}$info
		elif [[ $info == *"dynamically"* ]]; then
			echo -e ${RED}$info
		else
			echo -e "${RED}Error${NC} while reading file type of $WHISPER_APP_DIR"
		fi

		if [[ $2 == "memcached" ]]; then
			WHISPER_APP_DIR=$PATH_TO_MEMSLAP
			info=`file $WHISPER_APP_DIR`
			if [[ $info == *"statically"* ]]; then
				echo -e ${GREEN}$info
			elif [[ $info == *"dynamically"* ]]; then
				echo -e ${RED}$info
			else
				echo -e "${RED}Error${NC} while reading file type of $WHISPER_APP_DIR"
			fi
		fi

		if [[ $2 == "redis" ]]; then
			WHISPER_APP_DIR=$PATH_TO_REDIS_CLIENT
			info=`file $WHISPER_APP_DIR`
			if [[ $info == *"statically"* ]]; then
				echo -e ${GREEN}$info
			elif [[ $info == *"dynamically"* ]]; then
				echo -e ${RED}$info
			else
				echo -e "${RED}Error${NC} while reading file type of $WHISPER_APP_DIR"
			fi
		fi
	fi
}

func_launch_baremetal(){

	# Bring up a shell inside the simulated architecture
	# Do not redirect output

	$GEM5_INSTALL_DIR/build/X86_MESI_Two_Level/gem5.fast \
	--outdir=$GEM5_INSTALL_DIR/script/x86/zz_launch_baremetal/m5out \
	--redirect-stdout \
	--redirect-stderr \
	$GEM5_INSTALL_DIR/configs/example/fs.py \
	--ruby \
	--caches \
	--l2cache \
	-n 1 \
	--cpu-type=X86KvmCPU \
	--mem-size=16GB \
	--num-cpus=$CORE_NUM \
	--num-l2cache=$CORE_NUM  \
	--num-dirs=$CORE_NUM  \
	--topology=Mesh_XY \
	--mesh-rows=$CORE_NUM  \
	--disk-image=$FULL_IMG_DIR/$DISK_VER \
	--kernel=$FULL_KERNEL_DIR/$KERNEL_VER
}

main() {

	PROGRAM_SET=("ycsb" "tpcc" "echo" "memcached" "vacation" "ctree" "hashmap" "redis")

	PATH_TO_NSTORE="$HOME/Benchmarks/whisper/nstore/src/nstore"
	PATH_TO_ECHO="$HOME/Benchmarks/whisper/kv-echo/echo/src/evaluation/evaluation"
	PATH_TO_MEMCACHED="$HOME/Benchmarks/whisper/mnemosyne-gcc/usermode/build/bench/memcached/memcached-1.2.4-mtm/memcached"
	PATH_TO_MEMSLAP="$HOME/Benchmarks/whisper/mnemosyne-gcc/usermode/bench/memcached/memslap"
	PATH_TO_VACATION="$HOME/Benchmarks/whisper/mnemosyne-gcc/usermode/build/bench/stamp-kozy/vacation/vacation"
	PATH_TO_PMEMBEMCH="$HOME/Benchmarks/whisper/nvml/src/benchmarks/pmembench"
	PATH_TO_REDIS_SERVER="$HOME/Benchmarks/whisper/redis/src/redis-server"
	PATH_TO_REDIS_CLIENT="$HOME/Benchmarks/whisper/redis/src/redis-cli"

	RED='\033[0;31m'
	NC='\033[0m'
	GREEN='\033[0;32m'

	if [[ " $1 " =~ " build_whisper " ]]; then
		func_build_whisper "$@";

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
				1, ${GREEN}build_whisper${NC} + appname
				2, ${GREEN}check_build${NC} + appname/all
				3, ${GREEN}build_kernel${NC}
				4, ${GREEN}launch_baremetal${NC}"
		echo -e "Now exit..."
		exit -2;
	fi
}

main "$@"; exit
