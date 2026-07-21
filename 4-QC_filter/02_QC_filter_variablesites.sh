#!/bin/bash
#SBATCH -a 1-65
#SBATCH --cpus-per-task=2
#SBATCH --mem=30G
#SBATCH --time=0-1:00:00
#SBATCH --job-name=QC_filter
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to run quality filtering on VariableSites VCF 

###!!!###                                       ###!!!####
# determine the number of scaffolds you want to genotype #
#               change --array accordingly               #
###!!!###                                       ###!!!####
## NOTE: Because larger scaffolds will require more time and memory than smaller scaffolds, submit in chunks to avoid wasting resources 

# Load conda env (see vcf_environment.yaml for details)
module purge
module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /path/to/vcf_env

# Set variables for filtering thresholds
MISS=$1
MAF=$2
Q=$3

# Set scaffold (Linkage Group) name from .fai file
N=${SLURM_ARRAY_TASK_ID}
LG=$( head -n $N $REF.fai | tail -n 1 | cut -f 1 )

# Set paths
AB_script=/path/to/allelelic_imbalance_5.0.R
#AB_exclude=/path/to/samples.list #only if inital tests for allelic imbalance suggest removal of certain individuals.
REF=/path/to/ref_genome.fasta
VCF=/path/to/variablesitesvcf/variablesites
DIR=/path/to/variablesitesvcf/'tmp_miss'$MISS'_maf'$MAF'_Q'$Q
mkdir -p $DIR
TMP=$DIR/$LG'_variablesites'

###
# 1. Subsample vcf to select only current scaffold/linkage group 
###
bcftools view -Oz -o $TMP'_tmp1.vcf.gz' $VCF'_raw.vcf.gz' -r $LG
# -Oz save output as compressed vcf, -r selects the region to subsample (current chromosome/scaffold/linkage group)


###
# 2. Filter genotypes with DP < 3 (sets to missing)
###
vcftools  --gzvcf $TMP'_tmp1.vcf.gz' \
          --out 	$TMP'_tmp2' \
	        --minDP 3 \
	        --remove-indels \
	        --recode-INFO-all	--recode
mv $TMP'_tmp2.recode.vcf' $TMP'_tmp2.vcf'
bgzip $TMP'_tmp2.vcf'

###
# 3. Basic filter parameters
###
vcftools  --gzvcf $TMP'_tmp2.vcf.gz' \
          --out $TMP'_tmp3_miss'$MISS'_maf'$MAF'_Q'$Q	--max-missing $MISS \
		      --min-alleles 2		--max-alleles 2 \
		      --min-meanDP 8		--max-meanDP 30 \
		      --minQ $Q		--maf $MAF \
		      --recode-INFO-all	--recode
mv $TMP'_tmp3_miss'$MISS'_maf'$MAF'_Q'$Q'.recode.vcf' $TMP'_tmp3_miss'$MISS'_maf'$MAF'_Q'$Q'.vcf'
bgzip $TMP'_tmp3_miss'$MISS'_maf'$MAF'_Q'$Q'.vcf' 

###
# 4. Test for allelic imbalance
###
# Select output from VCF (genotypes)
vcftools  --gzvcf $TMP'_tmp3_miss'$MISS'_maf'$MAF'_Q'$Q'.vcf.gz' \
		      --out $TMP'_tmp4_miss'$MISS'_maf'$MAF'_Q'$Q \
		      --extract-FORMAT-info GT
# extract-FORMAT-info GT extracts all genotype entries from VCF file

# Select output from VCF (allelic depth)
vcftools  --gzvcf $TMP'_tmp3_miss'$MISS'_maf'$MAF'_Q'$Q'.vcf.gz' \
		      --out 	$TMP'_tmp4_miss'$MISS'_maf'$MAF'_Q'$Q			\
		      --extract-FORMAT-info AD
# extract-FORMAT-info AD extracts all allelic depth entries from VCF file

# Run binomial test to filter sites with allelic imbalance - could require high mem when many SNPs are to be analysed
Rscript $AB_script \
          --GT_file  $TMP'_tmp4_miss'$MISS'_maf'$MAF'_Q'$Q'.GT.FORMAT' \
					--AD_file  $TMP'_tmp4_miss'$MISS'_maf'$MAF'_Q'$Q'.AD.FORMAT' \
					--out_file $TMP'_tmp4_qc_miss'$MISS'_maf'$MAF'_Q'$Q \
					--conf.level 0.99 \
					--plots TRUE
#          --remove $AB_exclude	# if initial tests suggest removing certain individuals (assess plots created)

###
# 5. Remove sites suffering from allelic imbalance
###
vcftools --gzvcf $TMP'_tmp3_miss'$MISS'_maf'$MAF'_Q'$Q'.vcf.gz' \
		      --out $TMP'_tmp5_qc_miss'$MISS'_maf'$MAF'_Q'$Q \
		      --recode-INFO-all	--recode \
		      --exclude-positions $TMP'_tmp4_qc_miss'$MISS'_maf'$MAF'_Q'$Q'.exclude_pval0.01.list'
mv $TMP'_tmp5_qc_miss'$MISS'_maf'$MAF'_Q'$Q'.recode.vcf' $TMP'_tmp5_qc_miss'$MISS'_maf'$MAF'_Q'$Q'.vcf'
bgzip -fi $TMP'_tmp5_qc_miss'$MISS'_maf'$MAF'_Q'$Q'.vcf'
tabix -fp vcf $TMP'_tmp5_qc_miss'$MISS'_maf'$MAF'_Q'$Q'.vcf.gz'

conda deactivate


