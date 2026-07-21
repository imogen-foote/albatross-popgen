#!/bin/bash
#SBATCH -a 1-65
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=2-0:0:00
#SBATCH --job-name=QC_filter
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to run quality filtering on AllSites VCF, per scaffold
# When filtering AllSites VCF, need to apply Q filter only to variant sites
# This is because invariant sites have lower overall quality, so setting high Q threshold on them will result in significant data loss
# This involves splitting the full VCF into variant sites and invariant sites VCF and applying the Q filter only to variant sites VCF
# Then, merge them back together

###!!!###                                       ###!!!####
# determine the number of scaffolds you want to genotype #
#               change --array accordingly               #
###!!!###                                       ###!!!####

## Because larger scaffolds will require more time and memory than smaller scaffolds, submit in chunks to avoid wasting resources 
## e.g. -a 1-10 with 36h 500MB 
##	-a 11-25 with 12h 500MB
##	-a 26-45 with 5h 500MB
##	-a 46-65 with 2h 500MB

# Load conda env
module purge && module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /nesi/project/vuw03922/vcf_env

# Set variables for filtering thresholds
MISS=$1
Q=$2

# Set scaffold (Linkage Group) name from .fai file
N=${SLURM_ARRAY_TASK_ID}
LG=$( head -n $N $REF.fai | tail -n 1 | cut -f 1 )

# Set paths
REF=/path/to/ref_genome.fasta
VCF=/path/to/allsitesvcf/allsites
DIR=/path/to/allsitesvcf/'tmp_miss'$MISS'_Q'$Q
mkdir -p $DIR
TMP=$DIR/$LG'_'$SET

###
# 1. Subsample vcf to select only current scaffold/linkage group 
###
bcftools view -Oz -o $TMP'_tmp1.vcf.gz' $VCF'_raw.vcf.gz' -r $LG
#-Oz save output as compressed vcf, -r selects the region to subsample (current chromosome/scaffold/linkage group)

###
# 2. Filter genotypes with DP < 3 (sets to missing)
###
vcftools --gzvcf $TMP'_tmp1.vcf.gz' \
	--out 	$TMP'_tmp2' \
	--minDP 3 \
	--recode-INFO-all	--recode
mv $TMP'_tmp2.recode.vcf' $TMP'_tmp2.vcf'
bgzip $TMP'_tmp2.vcf'

###
# 3. Basic filter parameters
###
# Create a VCF containing only invariant sites (--max-maf 0) and filter
vcftools --gzvcf $TMP'_tmp2.vcf.gz' \
        --out $TMP'_tmp3_miss'$MISS'_Q'$Q'_invariant'	\
		    --max-maf 0 \
		    --remove-indels \
		    --max-missing $MISS \
        --min-meanDP 10	--max-meanDP 30 \
        --recode-INFO-all	--recode

mv $TMP'_tmp3_miss'$MISS'_Q'$Q'_invariant.recode.vcf' $TMP'_tmp3_miss'$MISS'_Q'$Q'_invariant.vcf'
bgzip $TMP'_tmp3_miss'$MISS'_Q'$Q'_invariant.vcf' 
tabix -fp vcf $TMP'_tmp3_miss'$MISS'_Q'$Q'_invariant.vcf.gz'

# Create a VCF containing only variant sites (--mac 1) and filter
vcftools --gzvcf $TMP'_tmp2.vcf.gz' \
        --out $TMP'_tmp3_miss'$MISS'_Q'$Q'_variant'	\
		    --mac 1 \
		    --remove-indels \
		    --minQ $Q \
		    --max-missing $MISS \
        --min-meanDP 10	--max-meanDP 30 \
        --recode-INFO-all	--recode

mv $TMP'_tmp3_miss'$MISS'_Q'$Q'_variant.recode.vcf' $TMP'_tmp3_miss'$MISS'_Q'$Q'_variant.vcf'
bgzip $TMP'_tmp3_miss'$MISS'_Q'$Q'_variant.vcf' 
tabix -fp vcf $TMP'_tmp3_miss'$MISS'_Q'$Q'_variant.vcf.gz'

# Merge filtered variant and invariant VCF files
bcftools concat \
    --allow-overlaps \
    $TMP'_tmp3_miss'$MISS'_Q'$Q'_invariant.vcf.gz' $TMP'_tmp3_miss'$MISS'_Q'$Q'_variant.vcf.gz' \
    -O z -o $TMP'_tmp3_miss'$MISS'_Q'$Q'.vcf.gz'

conda deactivate

