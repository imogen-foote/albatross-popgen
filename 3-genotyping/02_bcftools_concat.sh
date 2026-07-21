#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
#SBATCH --time=1-0:00:00
#SBATCH --job-name=bcf_concat
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to concatenate VCFs for each scaffold generated in the previous script

# Load modules
module load HTSlib/1.19-GCC-11.3.0
module load BCFtools/1.19-GCC-11.3.0

# Set paths 
VCF_NEW=/path/to/vcf_raw  # Path to save new (merged) VCF file
TMP_DIR=/path/to/vcf/tmp # Path where unmerged VCF files are located


# Merge vcf files in tmp dir
bcftools concat -Oz -o $VCF_NEW'.vcf.gz' $( ls -v $TMP_DIR/*'_raw_tmp2.vcf.gz' )
#$(ls ....) command substitution with the -v option lists and accesses files in numerical order so that scaffolds are ordered numerically in the resulting VCF file


# Create indexes for raw vcf file
tabix -p vcf $VCF_NEW'.vcf.gz'

# Remove tmp folder when you don't need it anymore
#rm -r $TMP_DIR


#State: COMPLETED
#Cores: 1
#Tasks: 1
#Nodes: 1
#Job Wall-time:    2.8%  00:08:28 of 05:00:00 time limit
#CPU Efficiency: 166.9%  00:14:08 of 00:08:28 core-walltime
#Mem Efficiency:   0.5%  20.97 MB of 4.00 GB

