#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=0-5:0:00
#SBATCH --job-name=hwe_filter
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

### Script to filter neutral SNP dataset by hwe (on each population separately)
## Should be run in series with removing outliers (step 1) and LD pruning (step 3) to produce final 'neutral SNPs' file

# Load conda env (see 4-QC_filter/vcf_environment.yaml for env specifics)
module purge
module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /nesi/project/vuw03922/vcf_env

# Set paths
vcf2R=/path/to/Rscripts/vcf2Rinput.R
gds2plink=/path/to/Rscripts/gds2plink.R
pop_file=/path/to/pop_info.tsv # 2 column (IND POP) tab delimited population file
VCF=/path/to/variablesitesvcf/variablesites
TMP=/path/to/variablesitesvcf/tmp

### The below sets will generate three different filtered datasets to compare

## Set hwe p value
hwe=0.001

###
# 1. "Out All" - Separate VCF into separate pops, then apply hwe filter to each
###

# Define pops
POPS=("Antipodean" "Gibsons")

FAIL_LISTS=()

# 1. Create VCF of failing SNPs per population
for POP in "${POPS[@]}"; do
    echo "Processing population: $POP"

    # Generate list of samples from that pop
    awk -v p="$POP" '$2==p {print $1}' $pop_file > $TMP/${POP}.txt

    # HWE test - produces .hwe file with p-value from hwe test for each SNP
    vcftools --gzvcf $TMP/${SET}_tmp1_no_outliers.vcf.gz \
        --keep $TMP/${POP}.txt \
        --hardy \
        --out $TMP/${POP}

    # Create list of SNP that are not in HWE - extract lines after the first line (NR>1) with final column value/p-value (NF) below thresh ($hwe), keep only CHR and POS columns ($1 and $2)
    awk -v thresh=$hwe 'NR>1 && $NF < thresh {print $1"\t"$2}' \
        $TMP/${POP}.hwe > $TMP/${POP}_fail.txt

    # Add this population fail file to array 
    FAIL_LISTS+=("$TMP/${POP}_fail.txt")

    # Warn if empty
    if [ ! -s $TMP/${POP}_fail.txt ]; then
        echo "Warning: no HWE failures in $POP"
    fi
done

echo "Finding SNPs failing in ALL populations..."

# Extract first population's fail list from array 
cp ${FAIL_LISTS[0]} $TMP/fail_all.txt

# Intersect with remaining populations fail lists to keep only snps that fail HWE in all pops
for FILE in "${FAIL_LISTS[@]:1}"; do
    awk 'NR==FNR {a[$1,$2]; next} ($1,$2) in a' \
        $TMP/fail_all.txt "$FILE" > $TMP/tmp.txt
    mv $TMP/tmp.txt $TMP/fail_all.txt
done


# Remove SNPs failing in ALL pops
echo "Filtering VCF (Out All)..."
bcftools view \
    -T ^$TMP/fail_all.txt \
    $TMP/tmp1_no_outliers.vcf.gz \
    -Oz -o $TMP/tmp2_hwe_OutAll.vcf.gz

tabix -fp vcf $TMP/tmp2_hwe_OutAll.vcf.gz


# Create gds from vcf so that can convert to plink format for pruning step
echo "Creating tmp gds (Out All)..."
Rscript $vcf2R --gzvcf $TMP/'tmp2_hwe_OutAll.vcf.gz'	\
		--snprelate_out $TMP/'tmp2_hwe_OutAll'

#creating plink files from gds
echo "Creating tmp plink files..."
Rscript $gds2plink --gds_file $TMP/'tmp2_hwe_OutAll.gds'	\
		--out $TMP/'tmp2_hwe_OutAll'			\
		--pop_file $pop_file

###
# 2. "Out Combo" - Apply HWE filtering across whole population (not split by population)
###
echo "Perfoming HWE filtering (Out Combo)..."

vcftools --gzvcf $TMP/'tmp1_no_outliers.vcf.gz'	\
			--hwe $hwe									\
			--recode-INFO-all --recode					\
			--out $TMP/tmp2_hwe_OutCombo

echo "Zipping and indexing VCF (Out Combo)..."
bgzip -c $TMP/'tmp2_hwe_OutCombo.recode.vcf' > $TMP/'tmp2_hwe_OutCombo.vcf.gz'
tabix -fp vcf $TMP/'tmp2_hwe_OutCombo.vcf.gz'

# Create gds from vcf so that can convert to plink format for pruning step
echo "Creating tmp gds (Out Combo)..."
Rscript $vcf2R --gzvcf $TMP/'tmp2_hwe_OutCombo.vcf.gz'	\
		--snprelate_out $TMP/'tmp2_hwe_OutCombo'

#creating plink files from gds
echo "Creating tmp plink files..."
Rscript $gds2plink --gds_file $TMP/'tmp2_hwe_OutCombo.gds'	\
		--out $TMP/'tmp2_hwe_OutCombo'			\
		--pop_file $pop_file

###
# 3. "No filter"
###

cp $TMP/'tmp1_no_outliers.vcf.gz' $TMP/'tmp2_hwe_NoFilter.vcf.gz'
tabix -fp vcf $TMP/'tmp2_hwe_NoFilter.vcf.gz'

# Create gds from vcf so that can convert to plink format for pruning step
echo "Creating tmp gds (No filter)..."
Rscript $vcf2R --gzvcf $TMP/'tmp2_hwe_NoFilter.vcf.gz'	\
		--snprelate_out $TMP/'tmp2_hwe_NoFilter'

#creating plink files from gds
echo "Creating tmp plink files..."
Rscript $gds2plink --gds_file $TMP/'tmp2_hwe_NoFilter.gds'	\
		--out $TMP/'tmp2_hwe_NoFilter'			\
		--pop_file $pop_file

conda deactivate



#State: COMPLETED
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:    42.6%  00:51:06 of 02:00:00 time limit
#CPU Utilisation:  49.1%  00:50:09 of 01:42:12 core-walltime
#Mem Utilisation:  43.3%  2.17 GB of 5.00 GB

