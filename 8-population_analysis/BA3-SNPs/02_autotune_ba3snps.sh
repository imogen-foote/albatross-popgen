#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=5G
#SBATCH --time=0-5:0:00
#SBATCH --job-name=autotune_ba3snps
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## This script runs the BA3-SNPs autotune script to optimise mixing parameters for the final BA3-SNPs run

# Load modules
module purge
module load GSL/2.7-GCC-11.3.0 
module load Boost/1.77.0-GCC-11.3.0 
module load gimkl/2022a

# Set paths
read=/path/to/out/ba3snps/neutral_subset
out=${read}/autotune
mkdir -p $out

# Count number of loci and assign to variable
n_loc=$(countLociImmanc.sh -f ${read}/neutral_subset_withpops.ba3 | tail -n 2 | head -n 1)
echo "Counted $n_loc SNPs."

# Run autotune script
BA3-SNPS-autotune/BA3-SNPS-autotune.py	\
	-i ${read}/${SET}_withpops.ba3	\
	-l $n_loc	-s 2946		\
	-o $out/neutral_subset.txt		\
	-r 20

#move output files to autotune directory
mv ${read}/neutral_subset*stdout $out
mv ${read}/neutral_subset*finalParams.txt $out
mv ${read}/neutral_subset*indiv.txt $out
mv ${read}/neutral_subset*trace.txt $out



#State: COMPLETED
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:    7.7%  03:42:58 of 2-00:00:00 time limit
#CPU Efficiency:  49.9%  03:42:34 of 07:25:56 core-walltime
#Mem Efficiency:  15.0%  3.01 GB of 20.00 GB

