#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=0-16:00:00
#SBATCH --job-name=QC_merge
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to merge filtered per-scaffold AllSites VCFs 

# Load conda env (see vcf_environment.yaml for env specifics)
module purge
module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /path/to/vcf_env

# Set variables for filtering thresholds
MISS=$3
Q=$4

# Set paths
vcf2R=/path/to/Rscripts/vcf2Rinput.R
gds2plink=/path/to/Rscripts/gds2plink.R
POP=/path/to/pop_info.tsv # 2 column tab-delimited population file (IND POP)
VCF=/path/to/allsitesvcf/'allsites_qc_miss'$MISS'_Q'$Q
TMP=/path/to/allsitesvcf/'tmp_miss'$MISS'_Q'$Q

# Merge VCF files in tmp dir
bcftools concat -Oz -o $VCF.vcf.gz $( ls -v $TMP/*'_tmp3_miss'$MISS'_Q'$Q'.vcf.gz' ) --threads 10
bgzip --reindex $VCF.vcf.gz
tabix -p vcf $VCF.vcf.gz

# Convert to GDS
Rscript $vcf2R --gzvcf $VCF.vcf.gz	\
		--snprelate_out $VCF

# Convert to plink bed file
Rscript $gds2plink --gds_file $VCF.gds	\
			--out $VCF		\
			--pop_file $POP

conda deactivate

# Remove tmp once you're sure you dont need the temporary output
#rm -r $TMP

#State: ['COMPLETED']
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:   44.1%  00:13:13 of 00:30:00 time limit
#CPU Efficiency:  69.5%  00:18:22 of 00:26:26 core-walltime
#Mem Efficiency:  99.9%  7.99 GB of 8.00 GB

