#!/bin/bash
#SBATCH --cpus-per-task=12
#SBATCH --mem=10G
#SBATCH --time=0-5:00
#SBATCH --job-name=fastqc
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script for running FastQC on raw, untrimmed Illumina reads

# Load modules
module purge
module load FastQC/0.12.1

# Params
PROJECT=$1 #Antipodean or Gibson's albatross
read_dir=/path/to/raw_data/illumina
output_dir=/path/to/out/fastqc/fastqc_raw
mkdir -p $output_dir

# Run FastQC
fastqc $read_dir/*.f*.gz  -t 12 --noextract --outdir $output_dir/


#State: COMPLETED
#Cores: 6
#Tasks: 1
#Nodes: 1
#Job Wall-time:   61.9%  03:05:43 of 05:00:00 time limit
#CPU Efficiency: 178.8%  1-09:12:05 of 18:34:18 core-walltime
#Mem Efficiency:  51.5%  5.15 GB of 10.00 GB

