#!/bin/bash -l

#SBATCH -A naiss2023-5-106 
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 240:00:00
#SBATCH -J run_parsec_starcraft_$1_$2

if [ "$#" -ne 2 ]; then
echo "Usage: $0 [BM_NAME] [CORE_NUM]"
exit 1
fi

BM_NAME=$1
CORE_NUM=$2

module purge

#load this for Scons
echo "load PROJ/8.1.0"
module load PROJ/8.1.0

echo "load HDF5" 
# choose one of these two versions as they use GCCcore-8.3.0 
# need this so that pkg-config can detect hdf5 and add linker flags
module load HDF5/1.10.5-gompi-2019b
#module load HDF5/1.10.5-iimpi-2019b

echo "load pkg-config"
module load pkg-config/0.29.2-GCCcore-8.3.0

echo "load Scons/3.1.1"
module load SCons/3.1.1-GCCcore-8.3.0

# if GCCCore/8.3.0 does not work (saying undefined instructions / Can't find working python version) load 10.3.0
echo "load gcc"
module load GCC/10.3.0

#echo "load Python/3.8.2"
#module load Python/3.8.2-GCCcore-9.3.0

GEM5_INSTALL_DIR="/proj/snic2022-23-302/yuan/Starcraft/starcraft-gem5"
IMAGE_INSTALL_DIR="/proj/snic2022-23-302/yuan/full_system_images"
KERNEL_VER="x86_64-vmlinux-3.2.24-smp-capcom"
DISK_VER="linux-x86-parsec-capcom.img"
CKPT_INSTALL_DIR="/proj/snic2022-23-302/yuan/Starcraft/starcraft-gem5"

echo "Gem5 with parsec (run w gem5 v22) ${BM_NAME} ${CORE_NUM}"
date

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

$GEM5_INSTALL_DIR/build/X86/gem5.fast \
    --outdir=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$BM_NAME/m5out/"${CORE_NUM}p" \
    --redirect-stdout \
    --redirect-stderr \
    $GEM5_INSTALL_DIR/configs/example/fs.py \
    --checkpoint-dir=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$BM_NAME/m5out/"${CORE_NUM}p" \
    --script=$GEM5_INSTALL_DIR/script/x86/parsec-3.0/$BM_NAME/"$i-${CORE_NUM}p".rcS \
    --cpu-type=TimingSimpleCPU \
    --ruby \
    --network=garnet \
    --caches \
    --l2cache \
    -n $CORE_NUM \
    --mem-size=4GB \
    --num-cpus=$CORE_NUM \
    --num-l2cache=$CORE_NUM \
    --num-dirs=$CORE_NUM \
    --topology=Mesh_XY \
    --mesh-rows=$ROW_NUM \
    --disk-image=$IMAGE_INSTALL_DIR/disks/x86/$DISK_VER \
    --kernel=$IMAGE_INSTALL_DIR/binaries/x86/$KERNEL_VER

echo "Finished!"
date
