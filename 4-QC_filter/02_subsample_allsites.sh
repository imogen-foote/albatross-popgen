#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=0-12:0:00
#SBATCH --job-name=downsamplevcf
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to randomly downsample AllSites VCF for data check (VCFstats) - full VCF is too large to run

# Load conda env (see vcf_environment.yaml for env specifics)
module purge
module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /path/to/vcf_env

# Set paths
VCF=/path/to/allitesvcf/'allsites_qc_miss0.95_Q30'
OUT_DIR=/path/to/out/vcfstats/qc
mkdir -p $OUT_DIR

###
## 1. Subsample
###
# Check input VCF exists
if [ ! -f "${VCF}.vcf.gz" ]; then
	echo "Input file missing: ${VCF}.vcf.gz" >&2
    exit 1
else
	echo "Input file ${VCF}.vcf.gz found, proceeding with subsampling..."
fi

# Produce list of 500000 random sites and extract CHROM and POS columns
bcftools query -f '%CHROM\t%POS\n' "${VCF}.vcf.gz" \
	| shuf -n 500000 \
	> ${VCF}'_subset_sites.txt'

# Select only these sites from full VCF
bcftools view \
	--threads 2 \
	--targets-file ${VCF}'_subset_sites.txt' \
	--output-type z \
	--output ${VCF}'_subset.vcf.gz' \
	${VCF}'.vcf.gz'

echo "Subsampling complete."

# Remove subset sites file
rm "${VCF}_subset_sites.txt"

# Check subset file exists
if [ ! -f "${VCF}_subset.vcf.gz" ]; then
	echo "Input file missing: ${VCF}_subset.vcf.gz" >&2
    exit 1
else
	echo "Input file ${VCF}_subset.vcf.gz found, proceeding with compression..."
fi


###
# 3. Index subsample VCF 
###
echo "Indexing ${VCF}_subset.vcf.gz..."
bcftools index \
	--threads 2 \
	${VCF}'_subset.vcf.gz'

###
# 4. Final check of number of sites in subsampled VCF
###
echo "Counting sites in ${VCF}_subset.vcf.gz..."
bcftools index -n ${VCF}'_subset.vcf.gz' > ${VCF}'_subset_nSNPs.txt'

conda deactivate

#State: COMPLETED
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:    56.9%  02:50:36 of 05:00:00 time limit
#CPU Utilisation:  57.6%  03:16:36 of 05:41:12 core-walltime
#Mem Utilisation:   9.0%  92.00 MB of 1.00 GB
