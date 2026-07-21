#!/bin/bash
#SBATCH -a 1-43
#SBATCH --cpus-per-task=2
#SBATCH --mem=35G
#SBATCH --time=0-12:0:00
#SBATCH --job-name=paleomix_bwa_mem
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to run paleomix BAM pipeline for 
# trimming of adapter sequences
# filtering of low quality reads 
# mapping of reads against the reference genome
# etc

# NOTE: set array according to the number of samples

# Activate conda env (see environment.yaml for env specifics)
module purge && module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /path/to/env/paleomix

# Set paths
N=${SLURM_ARRAY_TASK_ID}
sample_list=/path/to/resources/paleomix/samples.txt         # A txt file with list of sample names each on separate line
sample=$( head -n $N $sample_list | tail -n 1 | cut -f 1 )  # Set sample name by extract Nth sample from sample list, according to array N
read_dir=/path/to/data/paleomix/${sample}

# Run paleomix BAM pipeline
echo "running PALEOMIX"
cd $read_dir
paleomix bam run *.yaml

## Replace run with dryrun to do preliminary check that all files and required software is present

conda deactivate


#Array Job ID: 43223568_2
#State: COMPLETED
#Cores: 1
#Tasks: 1
#Nodes: 1
#Job Wall-time:   35.7%  17:09:06 of 2-00:00:00 time limit
#CPU Efficiency: 178.6%  1-06:38:05 of 17:09:06 core-walltime
#Mem Efficiency:  29.6%  8.88 GB of 30.00 GB


