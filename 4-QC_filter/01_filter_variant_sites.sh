#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=0-5:00:00
#SBATCH --job-name=filter_variants
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to create VCF with variant sites only (remove invariant sites)

# Load modules
module purge
module load BCFtools/1.19-GCC-11.3.0
module load HTSlib/1.19-GCC-11.3.0

# Set paths
VCF=/path/to/vcf/dir
allsites=$VCF/'allsites'/'allsites_raw.vcf.gz'
variablesites=$VCF/'variablesites'
mkdir -p $variablesites

# Filter VCF to retain only variable sites (remove invariant sites)
bcftools view -v snps -m2 -M2 -Oz -o $variablesites/'variablesites_raw.vcf.gz' $allsites

# Index filtered VCF
tabix -p vcf $variablesites/'variablesites_raw.vcf.gz'


#State: ['COMPLETED']
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:   77.1%  03:51:14 of 05:00:00 time limit
#CPU Efficiency:  49.6%  03:49:21 of 07:42:28 core-walltime
#Mem Efficiency:  99.6%  1.99 GB of 2.00 GB
