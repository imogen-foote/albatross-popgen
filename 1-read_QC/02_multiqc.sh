#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=6G
#SBATCH --time=0-3:00
#SBATCH --job-name=multiqc
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to aggregate FastQC output from raw Illumina read data and visualise using MultiQC

# Load modules
module purge
module load MultiQC/1.13-gimkl-2022a-Python-3.10.5

# Set paths
read_dir=/path/to/fastqc/fastqc_raw
out_dir=/path/to/out/multiqc/multiqc_raw
mkdir -p $out_dir

# Run MultiQC
multiqc $read_dir/ --outdir $out_dir
