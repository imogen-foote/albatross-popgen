#!/bin/bash
#SBATCH --cpus-per-task=4
#SBATCH --mem=2G
#SBATCH --time=2:00:00
#SBATCH --job-name=GONE
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## This script runs GONE to infer recent demographic history - run separately on each population

##Copy files from github##
#git clone https://github.com/esrud/GONE.git
GONE=/path/to/script_GONE.sh

# Set population (antipodean or gibsons)
pop=$1

# Set paths
read_dir=/path/to/neutralsnps/neutral_${pop}
out_dir=/path/to/out/GONE/${pop}
mkdir -p $out_dir

# Copy files to this directory for running
cp ${read_dir}.map ${read_dir}.ped .

# Run GONE
bash $GONE ${pop}

# Remove map and ped files
rm ${pop}.map ${pop}.ped

#move all output files to out_dir
mv OUTPUT* $out_dir
mv Output* $out_dir
mv TEMPORARY_FILES/ $out_dir
mv outfileHWD $out_dir
mv timefile $out_dir
mv seedfile $out_dir 



#State: COMPLETED
#Cores: 4
#Tasks: 1
#Nodes: 1
#Job Wall-time:    22.9%  00:27:27 of 02:00:00 time limit
#CPU Utilisation: 111.4%  02:02:16 of 01:49:48 core-walltime
#Mem Utilisation:  79.2%  1.58 GB of 2.00 GB

