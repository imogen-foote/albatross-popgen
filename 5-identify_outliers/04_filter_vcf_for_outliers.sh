#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=0:15:00
#SBATCH --job-name=filtervcf
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err


### Script to filter the full QC filtered VCF to retain only the outlier SNPs identified in both pcadapt and Baypass (overlapping outliers)
## requires a file containing the overlapping outliers identified in pcadapt and baypass - this is done in R###

# Set variables
miss=0.95
maf=0.05
Q=30
q=0.05
K=1
nSNP=$1 # number of overlapping outliers SNP

# Load modules
module purge
module load htslib/1.10.1
module load vcftools/0.1.16
module load GCC/13.3.0
module load R/4.4.2
module load plink/1.90

# Set paths
vcf2R=/path/to/Rscripts/vcf2Rinput.R
gds2plink=/path/to/Rscripts/gds2plink.R
VCF=/path/to/variablesitesvcf/variablesites
TMP=/path/to/variablesitesvcf/tmp
mkdir -p $TMP
outliers=/path/to/outliers/${nSNP}_overlapping_outliers.tsv
pop_file=/path/to/pop_info.tsv # (POP, IND tab delimited file)

###
# 1. Filter vcf file for outliers
###
if [ -e $outliers ]
then
 #outputting outlier vcf file containing all snps
 vcftools --gzvcf $VCF'_qc_miss'${miss}'_maf'${maf}'_Q'${Q}'.vcf.gz'             	\
               --positions $outliers	\
               --out $TMP/'outliers_'${nSNP}'snps_tmp'                           		\
               --recode-INFO-all                               				\
               --recode
 mv $TMP/'outliers_'${nSNP}'snps_tmp.recode.vcf' $TMP/'outliers_'${nSNP}'snps_tmp.vcf'
 bgzip $TMP/'outliers_'${nSNP}'snps_tmp.vcf'
else
    echo "Outlier file not found"
    exit 1
fi

###
# 2. Convert to plink format
###

# Create gds from vcf 
echo "Creating tmp outlier gds..."
Rscript $vcf2R --gzvcf $TMP/'outliers_'${nSNP}'snps_tmp.vcf.gz'	\
		--snprelate_out $TMP/'outliers_'${nSNP}'snps_tmp'
		
#creating plink files from gds
echo "Creating tmp plink files..."
Rscript $gds2plink --gds_file $TMP/'outliers_'${nSNP}'snps_tmp.gds'	\
		--out $TMP/'outliers_'${nSNP}'snps_tmp'			\
		--pop_file $pop_file
		
###
# 3. Perform LD pruning
###

# Perform pairwise LD pruning by removing one variant from a pair of SNPs if correlation coeff is greater than 0.2 within a 50-SNP window, advancing 5 SNPs at a time saves a file containing SNP positions to keep - independent SNPs
plink --bfile $TMP/'outliers_'${nSNP}'snps_tmp'		\
	--indep-pairwise 50 5 0.2	\
	--chr-set 65			\
	--out $TMP/'outliers_'${nSNP}'snps_tmp2_LD'


# Replace colons with tabs to make file compatible with vcftools
sed -i 's/:/\t/g' $TMP/'outliers_'${nSNP}'snps_tmp2_LD.prune.in' 

# Remove snps in LD as identified by previous step to extract independent SNPs
echo "Extracting independent outlier SNPs..."
# Uses output file from previous step of SNPs to keep 
vcftools --gzvcf $TMP/'outliers_'${nSNP}'snps_tmp.vcf.gz'	\
	--out $VCF'_outlier'						\
	--positions $TMP/'outliers_'${nSNP}'snps_tmp2_LD.prune.in'	\
	--recode-INFO-all --recode

###
# 4. File conversion
###

# Zip VCF
mv $VCF'_outlier.recode.vcf' $VCF'_outlier.vcf'
bgzip $VCF'_outlier.vcf'

# Convert to gds
echo "Creating outlier gds..."
Rscript $vcf2R --gzvcf $VCF'_outlier.vcf.gz' \
		--snprelate_out $VCF'_outlier'

# Convert to plink
echo "Creating outlier plink files..."
Rscript $gds2plink --gds_file $VCF'_outlier.gds'	\
		--out $VCF'_outlier'			\
		--pop_file $pop_file


#State: COMPLETED
#Cores: 1
#Tasks: 1
#Nodes: 1
#Job Wall-time:   21.7%  00:01:05 of 00:05:00 time limit
#CPU Efficiency:  92.3%  00:01:00 of 00:01:05 core-walltime
#Mem Efficiency:   4.7%  241.99 MB of 5.00 GB

