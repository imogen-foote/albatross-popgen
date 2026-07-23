#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=5G
#SBATCH --time=4-0:0:00
#SBATCH --job-name=ba3snps
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to run BA3-SNPs using the mixing parameters determined from the autotune script

# Load modules
module purge
module load GSL/2.7-GCC-11.3.0 
module load Boost/1.77.0-GCC-11.3.0 
module load gimkl/2022a

# Set paths
read=/path/to/out/ba3snps/neutralsnps/neutral_subset
out=/path/to/out/ba3snps/neutralsnps
mkdir -p $out

# Set seed
SEED=$1

###
# 1. Count number of loci and assign to variable
###
n_loc=$(countLociImmanc.sh -f ${read}_withpops.ba3 | tail -n 2 | head -n 1)
echo "Counted $n_loc SNPs."


###
# 2. Set parameters obtained from autotune script (finalParams.txt)
###
m=0.1
a=0.2125
f=0.0047


###
# 3. Run BA3-SNPs
###
BA3-SNPS -v -u -t -g							\
	-b1500000	-i15000000					\
	--file ${read}_withpops.ba3 				\
	-o ${out}/neutral_subset_s${SEED}_m${m}_a${a}_f${f}_L${n_loc}.txt	\
	--loci $n_loc 							\
	-s $SEED							\
	-m $m	-a $a	-f $f

# Move stdout and trace file to output directory
cp /path/to/stdout/ba3snps.$SLURM_JOB_ID.out $out/ba3snps.$SLURM_JOB_ID_s${SEED}_m${m}_a${a}_f${f}_L${n_loc}.out
mv ${read}*trace.txt $out/neutral_subset_s${SEED}_m${m}_a${a}_f${f}_L${n_loc}_trace.txt
mv ${read}*indiv.txt $out/neutral_subset_s${SEED}_m${m}_a${a}_f${f}_L${n_loc}_indiv.txt



#Cores: 1
#Tasks: 1
#Nodes: 1
#Job Wall-time:   89.1%  2-16:07:51 of 3-00:00:00 time limit
#CPU Efficiency: 100.0%  2-16:06:08 of 2-16:07:51 core-walltime
#Mem Efficiency:  58.9%  2.94 GB of 5.00 GB

