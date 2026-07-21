#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=0-0:30:00
#SBATCH --job-name=QC_merge
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to merge filtered per-scaffold VariableSites VCFs 

# Load conda env
module purge
module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /path/to/vcf_env

# Set variables for filtering thresholds
MISS=$3
MAF=$4
Q=$5

# Set paths
vcf2R=/path/to/Rscripts/vcf2Rinput.R
gds2plink=/path/to/Rscripts/gds2plink.R
POP=/path/to/pop_info.tsv # 2 column tab-delimited population file (POP IND)
VCF=/path/to/variablesitesvcf/'variablesites_qc_miss'$MISS'_maf'$MAF'_Q'$Q
TMP=/path/to/variablesitesvcf/'tmp_miss'$MISS'_maf'$MAF'_Q'$Q

# Merge VCF files in tmp dir
bcftools concat -Oz -o $VCF.vcf.gz $( ls -v $TMP/*'_tmp5_qc_miss'$MISS'_maf'$MAF'_Q'$Q'.vcf.gz' ) --threads 10
bgzip --reindex $VCF.vcf.gz
tabix -p vcf $VCF.vcf.gz

# Convert VCF to GDS
Rscript $vcf2R --gzvcf $VCF.vcf.gz	\
		--snprelate_out $VCF

# Convert to plink bed file
Rscript $gds2plink --gds_file $VCF.gds	\
			--out $VCF		\
			--pop_file $POP

conda deactivate

# Remove tmp directory when you don't need it anymore
#rm -r $TMP


