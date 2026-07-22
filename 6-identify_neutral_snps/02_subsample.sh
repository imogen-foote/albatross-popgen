#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=0-0:10:00
#SBATCH --job-name=subsample_vcf
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to randomly subsample final neutral VCF for programmes that do not deal well with large datasets (NeEstimator, BA3-SNPs etc)

# Load packages
module purge
module load vcflib/1.0.1-GCC-9.2.0
module load BCFtools/1.13-GCC-9.2.0
module load HTSlib/1.19-GCC-11.3.0

## For Antipodean data
# Set paths
VCF=/path/to/variablesitesvcf/variablesites

# Randomly select ~ 10,000 snps from full dataset (10,000 / [total N SNPs in full dataset] for sampling rate)
rate=0.03
bcftools view $VCF'_neutral_OutAll.vcf.gz' | vcfrandomsample -r $rate > $VCF'_neutral_OutAll_subset.vcf'

bgzip $VCF'_neutral_OutAll_subset.vcf'
