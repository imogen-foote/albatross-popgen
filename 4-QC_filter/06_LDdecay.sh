#!/bin/bash
#SBATCH --cpus-per-task=4
#SBATCH --mem=30G
#SBATCH --time=0:30:00
#SBATCH --job-name=LDdecay
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to calculate Linkage Decay

# Load modules
module purge
module load HTSlib/1.19-GCC-11.3.0
module load PLINK/1.09b6.16
module load R/4.3.2-foss-2023a

## Set paths
VCF=/path/to/variablesitesvcf/variablesites
OUT=/path/to/out/LDdecay/variablesites
mkdir -p $OUT

###
## Calc LD with plink
###
echo "starting plink"

for CHR in {1..65}; do
	echo "Processing chromosome ${CHR}"

	plink	--bfile $VCF'_qc_miss0.95_maf0.05_Q30'	\
	      --allow-extra-chr \
	      --double-id	--set-missing-var-ids @:#	\
	      --maf 0.05	--chr-set 65 \
	      --thin 0.1	-r2 gz	--ld-window 100 \
	      --ld-window-kb 1000	--ld-window-r2 0 \
	      --chr ${CHR} \
	      --out $OUT/${SET}_chr${CHR}_qc_plink

bgzip -cd $OUT/${SET}_chr${CHR}_qc_plink.ld.gz | sed 's/[[:space:]]\+/\t/g' > $OUT/${SET}_chr${CHR}_qc_plink.ld
	
done


# Plot with R
