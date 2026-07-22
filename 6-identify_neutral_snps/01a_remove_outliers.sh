#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=0-1:0:00
#SBATCH --job-name=rm_outliers
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

### Script to filter QC VCF to remove outliers (all outliers), retaining only neutral SNPs
## Should be run in series with hwe filter (step 2) and LD pruning (step 3) to produce final 'neutral SNPs' file

# Load conda env (see 4-QC_filter/vcf_environment.yaml for env specifics)
module purge 
module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /nesi/project/vuw03922/vcf_env 


# Set variables
K=$1 #K values used for pcadapt
miss=0.95
maf=0.05
Q=30

# Set paths
vcf2R=/path/to/Rscripts/vcf2Rinput.R
gds2plink=/path/to/Rscripts/gds2plink.R
VCF=/path/to/variablesitesvcf/variablesites
TMP=/path/to/variablesitesvcf/tmp
mkdir -p $TMP
outlier=/path/to/out
PCADAPT=$outlier/pcadapt
BAYPASS=$outlier/baypass

###
# 1. Extract all SNPS identified as outliers by pcadapt and outflank and create new txt file containing the names of all unique values
###
#extract SNP names identified by pcadapt
awk 'NR>1 {print $2}' $PCADAPT/q0.05/*K${K}_q0.05_all_outliers.tsv > $TMP/pcadapt_outliers.txt

#extract SNP names identified by Baypass
awk 'NR>1 {print $8}' $BAYPASS/*_outliers_SNPIDs.txt > $TMP/baypass_outliers.txt

#combine
cat $TMP/pcadapt_outliers.txt $TMP/baypass_outliers.txt | sort -u > $TMP/all_outliers.txt

#format file correctly (chrom and pos) column
awk -F':' '{print $1"\t"$2}' $TMP/all_outliers.txt > $TMP/all_outliers_pos.txt

###
# 2. Filter VCF to remove outlier SNPs
###
echo "Removing outliers..."
if [ -e $TMP/all_outliers_pos.txt ]; then
 echo "$TMP/all_outliers_pos.txt found."
 #remove outliers
 vcftools 	--gzvcf $VCF'_qc_miss'${miss}'_maf'${maf}'_Q'${Q}'.vcf.gz'	\
			--out $TMP/'tmp1_no_outliers'										\
			--exclude-positions $TMP/all_outliers_pos.txt 				\
			--recode-INFO-all --recode
else
    echo "ERROR: $TMP/all_outliers_pos.txt not found."
    exit 1
fi 
bgzip -c $TMP/'tmp1_no_outliers.recode.vcf' > $TMP/'tmp1_no_outliers.vcf.gz'


conda deactivate

#State: COMPLETED
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:     2.8%  00:16:32 of 10:00:00 time limit
#CPU Utilisation:  49.6%  00:16:23 of 00:33:04 core-walltime
#Mem Utilisation:   0.1%  4.37 MB of 5.00 GB
