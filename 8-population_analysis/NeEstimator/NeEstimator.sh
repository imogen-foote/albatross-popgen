#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH --time=0-3:0:00
#SBATCH --job-name=NeEst
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## This script is to run NeEstimator to estimate effective population size

# Load modules
module purge
module load R/4.3.2-foss-2023a
module load GDAL/3.6.4-gompi-2023a
module load GEOS/3.11.3-GCC-12.3.0
module load PROJ/9.3.0-GCCcore-12.3.0

# Set paths
WORKDIR=/path/to/out/NeEstimator
R_gl2genepop=/path/to/Rscripts/gl2genepop.R
NE=/path/to/excecutable/NeEstimator2/Ne2-1L
cd $WORKDIR

###
# 1. Create Genlight input file
###
Rscript $R_gl2genepop


###
# 2. Run NeEstimator
###
echo "Working directory:" 
pwd
ls -lh

echo "Running NeEstimator..."

$NE i:info.txt o:option.txt

## NOTE: this script requires info.txt and option.txt files to set parameters of run 

echo "Done"
