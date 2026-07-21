#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=500M
#SBATCH --time=0-0:10:00
#SBATCH --job-name=vcfstats
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to check characteristics with VCFstats of the data to determine filtering thresholds 
# Run on VariableSites data and subsampled AllSites data
# Can also run again after filtering to see how filtering impacted data

# Load modules
module load HTSlib/1.19-GCC-11.3.0
module load VCFtools/0.1.15-GCC-9.2.0-Perl-5.30.1

# Set paths
VCF=/path/to/variablesitesvcf/'variablesites_raw_miss0.95_Q30_subset.vcf.gz'
OUT_DIR=/path/to/out/vcfstats/raw
mkdir -p $OUT_DIR

# Calculate allele frequency
vcftools --gzvcf $VCF --freq --out $OUT_DIR/$SET'_site_freq' --max-alleles 2

# Calculate allele frequency (for MAF spectrum)
vcftools --gzvcf $VCF --freq2 --out $OUT_DIR/$SET'_maf_biallelic' --max-alleles 2

# Calculate mean depth per individual
vcftools --gzvcf $VCF --depth --out $OUT_DIR/$SET'_mean_depth'

# Calculate mean depth per site
vcftools --gzvcf $VCF --site-mean-depth --out $OUT_DIR/$SET'_site_mean_depth'

# Calculate quality score per site
vcftools --gzvcf $VCF --site-quality --out $OUT_DIR/$SET'_site_qual'

# Calculate proportion missing data per individual
vcftools --gzvcf $VCF --missing-indv --out $OUT_DIR/$SET'_inv_missingness'

# Calculate proportion missing data per site
vcftools --gzvcf $VCF --missing-site --out $OUT_DIR/$SET'_site_missingness'

# Calculate heteryozygosity and inbreeding coefficient per individual
# Note: expected het might be overestimated if samples not all from sample pop due to Wahlund effect
vcftools --gzvcf $VCF --het --out $OUT_DIR/$SET'_het_inbreed'


#State: COMPLETED
#Cores: 1
#Tasks: 1
#Nodes: 1
#Job Wall-time:   15.7%  00:18:52 of 02:00:00 time limit
#CPU Efficiency:  99.3%  00:18:44 of 00:18:52 core-walltime
#Mem Efficiency:   0.1%  3.80 MB of 5.00 GB

