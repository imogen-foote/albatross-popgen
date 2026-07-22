#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=5G
#SBATCH --time=0:10:00
#SBATCH --job-name=pcadapt
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to run pcadapt on quality filtered VariableSites VCF to identify outlier SNPs

# Activate conda environment
module purge
module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /nesi/project/vuw03922/vcf_env

# Set paths
pcadapt=/path/to/Rscripts/pcadapt_shell.R
vcf2R=/path/to/Rscripts/vcf2Rinput.R
VCF=/path/to/variablesitesvcs/'variablesites_qc_miss0.95_maf0.05_Q30'
PCADAPT=/path/to/out/pcadapt
mkdir -p $PCADAPT

###
# Run pcadapt
###
K=$1
QVAL=0.05  
mkdir -p $PCADAPT/q${QVAL}

echo "Running pcadapt..."

Rscript $pcadapt --plink $VCF	\
			--out $PCADAPT/q${QVAL}/$SET	\
			--K0 10				\
			--K $K				\
			--maf 0.05			\
			--q $QVAL			\
			--slw 10000			\
			--minNsnp 2			\
			--mode full

if [ -e $PCADAPT/$SET*'_K'$K'_q'$QVAL'_all_outliers.tsv' ]; then
	echo "pcadapt output written to $PCADAPT/q${QVAL}/$SET, proceeding..." 
fi

conda deactivate


#State: ['COMPLETED']
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:    4.1%  00:04:54 of 02:00:00 time limit
#CPU Efficiency:  49.0%  00:04:48 of 00:09:48 core-walltime
#Mem Efficiency:  70.8%  3.54 GB of 5.00 GB
