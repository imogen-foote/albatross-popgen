#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=0:05:00
#SBATCH --job-name=filtervcf
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

### Script to filter the full QC filtered VCF to retain only the outlier SNPs identified in both pcadapt and Baypass (overlapping outliers)
## requires a file containing the overlapping outliers identified in pcadapt and baypass - this is done in R###

# Load modules
module purge
module load HTSlib/1.19-GCC-11.3.0
module load VCFtools/0.1.15-GCC-9.2.0-Perl-5.30.1
module load R/4.3.1-gimkl-2022a

# Set variables
miss=0.95
maf=0.05
Q=30
q=0.05
K=1
nSNP=$1 # number of overlapping outlier loci

# Set paths
vcf2R=/path/to/Rscripts/vcf2Rinput.R
VCF=/path/to/variablesitesvcf/variablesites
outliers=/path/to/out/outliers

###
# Filter vcf file for outliers
###
if [ -e $outliers/${PROJECT}_${nSNP}_overlapping_outliers.tsv ]
then
 #outputting outlier vcf file containing all snps
 vcftools --gzvcf $VCF'_qc_miss'${miss}'_maf'${maf}'_Q'${Q}'.vcf.gz'             	\
               --positions $outliers/${PROJECT}'_'${nSNP}'_overlapping_outliers.tsv'	\
               --out $VCF'_outliers_'${nSNP}'snps'                           		\
               --recode-INFO-all                               				\
               --recode
 mv $VCF'_outliers_'${nSNP}'snps.recode.vcf' $VCF'_outliers_'${nSNP}'snps.vcf'
 bgzip $VCF'_outliers_'${nSNP}'snps.vcf'

 Rscript $vcf2R --gzvcf $VCF'_outliers_'${nSNP}'snps.vcf.gz' 	\
               	--snprelate_out $VCF'_outliers_'${nSNP}'snps'	\
		--genlight_out $VCF'_outliers_'${nSNP}'snps'
fi


#State: COMPLETED
#Cores: 1
#Tasks: 1
#Nodes: 1
#Job Wall-time:   21.7%  00:01:05 of 00:05:00 time limit
#CPU Efficiency:  92.3%  00:01:00 of 00:01:05 core-walltime
#Mem Efficiency:   4.7%  241.99 MB of 5.00 GB

