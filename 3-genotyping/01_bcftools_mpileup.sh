#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH -a 1-65
#SBATCH --mem=1G
#SBATCH --time=0-0:10:00
#SBATCH --job-name=mpileup
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to perform variant calling using bcftools mpileup command
# This script will perform variant calling per scaffold/chromosome, and the output from each will be concatenated in the next step 

###!!!###              ###!!!####              ###!!!####         
# determine the number of scaffold you want to genotype #
#               change --array accordingly		          #
###!!!###              ###!!!####              ###!!!####
# NOTE: can submit in batches to manage resources as larger scaffolds will take longer/use more memory

# Load modules
module load HTSlib/1.19-GCC-11.3.0
module load BCFtools/1.19-GCC-11.3.0

# Set paths
SCAFFOLD=${SLURM_ARRAY_TASK_ID}
TMP_DIR=/path/to/snp/tmp
mkdir -p $TMP_DIR

REFERENCE=/path/to/ref_genome.fasta
FAI=/path/to/ref_genome.fasta.fai

BAMLIST=/path/to/bam.list # A txt file with paths to bam files (each line contains path for different sample)
REGION=$( head -n $SCAFFOLD $FAI | tail -n 1 | cut -f 1 ) # extract scaffold name from .fai file according to array N

# Genotype
bcftools mpileup -Oz \
		-a 'FORMAT/AD,FORMAT/DP,FORMAT/SP,FORMAT/ADF,FORMAT/ADR,INFO/AD' \
		-f $REFERENCE \
		-r $REGION \
		-b $BAMLIST |
bcftools call -Oz -m -f GQ > $TMP_DIR/'raw_tmp1.vcf'
# Note: This produces vcf containing ALL sites (variant and invariant) which are required for downstream analysis (pixy)
# So, invariant sites will be filtered out at a later step, however if you wanted to remove them during genotyping use -v flag 

# Update INFO fields
bcftools	+fill-tags 	$TMP_DIR/'raw_tmp1.vcf' \
		-Oz -o $TMP_DIR/'raw_tmp2.vcf.gz' \
		-- -t AC,AF,AN,MAF,NS,AC_Hom,AC_Het
bgzip --reindex $TMP_DIR/'raw_tmp2.vcf.gz'

rm $TMP_DIR/'raw_tmp1.vcf'


# Jobs in array took varying amounts of time. Smallest scaffolds took only a few minutes, while the largest (scaffold 1) is shown below. 
#State: COMPLETED
#Cores: 1
#Tasks: 1
#Nodes: 1
#Job Wall-time:   68.9%  1-09:05:31 of 2-00:00:00 time limit
#CPU Efficiency: 120.4%  1-15:49:59 of 1-09:05:31 core-walltime
#Mem Efficiency:  25.4%  260.11 MB of 1.00 GB

