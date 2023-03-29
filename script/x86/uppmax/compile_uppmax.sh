#!/bin/bash -l

#SBATCH -A naiss2023-5-106
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 02:30:00
#SBATCH -J compile_starcraft

module purge

#load module for scons
echo "load PROJ/8.1.0"
module load PROJ/8.1.0
# choose one of these two versions as they use GCCcore-8.3.0
# need this so that pkg-config can detect hdf5 and add linker flags

echo "load HDF5"
module load HDF5/1.10.5-gompi-2019b
#module load HDF5/1.10.5-iimpi-2019b

echo "load pkg-config"
module load pkg-config/0.29.2-GCCcore-8.3.0

echo "load Scons/3.1.1"
module load SCons/3.1.1-GCCcore-8.3.0

# if GCCCore/8.3.0 does not work (saying undefined instructions / Can't find working python version) load 10.3.0
echo "load gcc"
module load GCC/10.3.0

#echo "load Python/3.7.4"
#module load Python/3.7.4-GCCcore-8.3.0

#echo "load pybind11" # try this if python version check does not pass
#pip install --user pybind11

echo "check python3-config"
which python3-config
PYTHON3_CONFIG=$(which python3-config)

export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 # to let pkg-config output clfags
echo "check hdf5 with pkg-config"
pkg-config --cflags-only-I --libs-only-L hdf5
pkg-config --cflags-only-I --libs-only-L hdf5-serial
# It turns out setting that env var only works for the commands in this script but not for SCons

echo "gcc version"
gcc --version

echo "python version"
python --version

cd /proj/snic2022-23-302/yuan/Starcraft/starcraft-gem5/
scons PYTHON_CONFIG=$PYTHON3_CONFIG PROTOCOL=MOESI_hammer build/X86/gem5.fast -j 4

unset PKG_CONFIG_ALLOW_SYSTEM_CFLAGS
echo "finished!"
