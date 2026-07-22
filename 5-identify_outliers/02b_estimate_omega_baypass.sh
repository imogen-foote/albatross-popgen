#!/bin/bash
#SBATCH -a 1-3
#SBATCH --cpus-per-task=8
#SBATCH --mem=2G
#SBATCH --time=0:30:00
#SBATCH --job-name=baypass_est_omega
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to estimate the correct value of omega to use in Baypass run

### Estimate 3 random omega matrices using BayPass v3.0
## Each array task will:
#   - Create a random subset of 100,000 SNPs
#   - Run BayPass on that subset
#   - Store outputs in omega_est/

# Load modules
module purge
module load BayPass/3.0-GCC-12.3.0

# Set paths
baypass=/path/to/out/baypass
input_file=$baypass/variablesites_baypass_input.txt
out_dir=$baypass/omega_est
mkdir -p $out_dir

###
# 1. Create random subset of 100,000 SNPs 
###
echo "Creating random SNP subset..."
NSNPS=100000
subset_file=$out_dir/subset${SLURM_ARRAY_TASK_ID}.txt
shuf -n $NSNPS $input_file > $subset_file

###
# 2. Run Baypass on subset file
###
# Set outprefix for subset
output_prefix=$out_dir/omega_subset${SLURM_ARRAY_TASK_ID}

echo "Running Baypass on SNP subset..."
# Then run Baypass
baypass -countdatafile $subset_file \
		-outprefix $output_prefix \
		-nthreads 8

###
# 3. Following this calculate correlation matrix for 3 prefix_mat_omega.out files in R
###
# Check that correlation between 3 output files is high
# If so, use any for input into actual Baypass run


#State: ['COMPLETED']
#Cores: 8
#Tasks: 1
#Nodes: 1
#Job Wall-time:    6.5%  00:11:45 of 03:00:00 time limit
#CPU Efficiency:  97.7%  01:31:48 of 01:34:00 core-walltime
#Mem Efficiency:   1.0%  79.45 MB of 8.00 GB
