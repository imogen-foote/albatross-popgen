#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=5G
#SBATCH --time=0-1:0:00
#SBATCH --job-name=LD_prune
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

### Script to filter neutral SNP VCF for LD
## Should be run in series with removing outliers (step 1) and hwe filtering (step 2) to produce final 'neutral SNPs' file

## Load conda env (see 4-QC_filter/vcf_environment.yaml for env specifics)
module purge && module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /nesi/project/vuw03922/vcf_env

# Set varaiables
HWFILTER=$3 ## Out All, Out Combo or No Filter

# Set paths
vcf2R=/path/to/Rscripts/vcf2Rinput.R
gds2plink=/path/to/Rscripts/gds2plink.R
pop_file=/path/to/'pop_info.tsv' # 2 column (IND POP) tab delimited population file
VCF=/path/to/variablesitesvcf/variablesites
TMP=/path/to/variablesitesvcf/tmp


###
# 1. "Out All" - Filter sites in LD
###
echo "Filtering linked sites (${HWFILTER})..."
# Perform pairwise LD pruning by removing one variant from a pair of SNPs if correlation coeff is greater than 0.2 within a 50-SNP window, advancing 5 SNPs at a time saves a file containing SNP positions to keep - independent SNPs
plink --bfile $TMP/'tmp2_hwe_'${HWFILTER}		\
	--indep-pairwise 50 5 0.2	\
	--chr-set 65			\
	--out $TMP/'tmp3_LD_'${HWFILTER}


# Replace colons with tabs to make file compatible with vcftools
sed -i 's/:/\t/g' $TMP/'tmp3_LD_'${HWFILTER}'.prune.in' 

# Remove snps in LD as identified by previous step to extract independent SNPs
echo "Extracting independent SNPs (${HWFILTER})..."
# Uses output file from previous step of SNPs to keep 
vcftools --gzvcf $TMP/'tmp2_hwe_'${HWFILTER}'.vcf.gz'	\
	--out $VCF'_neutral_'${HWFILTER}						\
	--positions $TMP/'tmp3_LD_'${HWFILTER}'.prune.in'	\
	--recode-INFO-all --recode

###
# 2. File conversion
###

# Zip VCF
mv $VCF'_neutral_'${HWFILTER}'.recode.vcf' $VCF'_neutral_'${HWFILTER}'.vcf'
bgzip $VCF'_neutral_'${HWFILTER}'.vcf'

# Convert to gds
echo "Creating gds (${HWFILTER})..."
Rscript $vcf2R --gzvcf $VCF'_neutral_'${HWFILTER}'.vcf.gz' \
		--snprelate_out $VCF'_neutral_'${HWFILTER}

# Convert to plink
echo "Creating plink files..."
Rscript $gds2plink --gds_file $VCF'_neutral_'${HWFILTER}'.gds'	\
		--out $VCF'_neutral_'${HWFILTER}			\
		--pop_file $pop_file
		
		
# Clean up
#rm -r $TMP/


#State: COMPLETED
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:     2.9%  00:05:17 of 03:00:00 time limit
#CPU Utilisation:  48.8%  00:05:09 of 00:10:34 core-walltime
#Mem Utilisation:  28.2%  577.70 MB of 2.00 GB
