#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=0:05:00
#SBATCH --job-name=plink2baypass
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err


## Script to create files approprite for BayPass input from plink format

MISS=0.95
MAF=0.05
Q=30

## Load packages
module purge
module load PLINK/1.09b6.16

## Set paths
pop_file=/path/to/sample_info #separate files for each population, specifying the pop ID (first column; no headers) and ind ID (second column; must match the population listed in the .fam file)
bed_file=/path/to/variablesitesvcf/variablesites_qc_miss0.95_maf0.05_Q30
baypass=/path/to/out/baypass
mkdir -p $baypass

###
# 1. Convert plink .bed file to allele freq count data
###
plink --bfile $bed_file --keep $pop_file/Antipodean_pop.txt --freq counts --chr-set 65 --out $baypass/antipodean
plink --bfile $bed_file --keep $pop_file/Gibsons_pop.txt --freq counts --chr-set 65 --out $baypass/gibsons
# This gives output with columns 'CHR', 'SNP', 'A1' (allele 1), 'A2', 'C1' (count allele 1), 'C2' and 'G0' (I think number of missing genotypes at this SNP, 0 meaning none missing)
# Baypass needs a plain text file with one line per SNP (no header); first/second columns are ref and alt allele count for pop 1, third/fourth are ref and alt counts for pop 2 etc

# Before converting to final Baypass format, we need to check the variants are in the same order in both files (crucial for baypass input) - exit job if not
awk 'NR > 1 {print $2}' $baypass/antipodean.frq.counts > $baypass/snps_antipodean.txt
awk 'NR > 1 {print $2}' $baypass/gibsons.frq.counts > $baypass/snps_gibsons.txt

if ! diff -q $baypass/snps_antipodean.txt $baypass/snps_gibsons.txt > /dev/null; then
    echo "ERROR: SNPs in antipodean and gibsons files are not in the same order or don't match." >&2
    exit 1
fi

###
# 2. Create a list of SNPs and assign line numbers, that will be used later to find matching line numbers in Baypass output (where SNP ID is lost)
###
awk '{print $1"\t"$4"\t"$2"\t"NR}' $bed_file.bim > $baypass/snp_ids.txt

###
# 3. Extract A1_count and A2_count columns from step 1 and paste into new .txt file for Baypass input
###
paste <(awk 'NR > 1 {print $5, $6}' $baypass/antipodean.frq.counts) \
      <(awk 'NR > 1 {print $5, $6}' $baypass/gibsons.frq.counts) \
      > $baypass/baypass_input.txt

###
# 3. Clean up temporary files
###
rm $baypass/snps_antipodean.txt $baypass/snps_gibsons.txt


#State: COMPLETED
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:     2.3%  00:00:07 of 00:05:00 time limit
#CPU Utilisation:  56.4%  00:00:07 of 00:00:14 core-walltime
#Mem Utilisation:   0.0%  0.00 MB of 1.00 GB
