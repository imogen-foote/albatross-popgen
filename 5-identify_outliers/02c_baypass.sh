#!/bin/bash
#SBATCH --cpus-per-task=8
#SBATCH --mem=3G
#SBATCH --time=8:00:00
#SBATCH --job-name=baypass
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

### Script to run Baypass on quality filtered VariableSites VCF to identify outlier SNPs

# Load modules
module purge
module load BayPass/3.0-GCC-12.3.0
module load R/4.3.2-foss-2023a

# Set paths
baypass=/path/to/out/baypass
input_file=$baypass/${SET}_baypass_input.txt
omega=$baypass/omega_est/omega_subset1_mat_omega.out
baypass_simulate=./baypass_simulate_data.R
baypass_threshold=./baypass_calculate_threshold.R
baypass_R=./baypass_utils.R

###
# 1. Run Baypass
###
echo "Beginning Baypass..."

baypass -countdatafile $input_file \
	-outprefix $baypass/${SET} \
	-omegafile $omega \
	-nthreads 8

###
# 2. Create simulated neutral SNP dataset to find XtX threshold for determining outlier SNPs 
###
echo "Simulating data to determine XtX threshold..."

# set paths to baypass output from above
beta=$baypass/${SET}_summary_beta_params.out
sim_out=$baypass/simulated_data
mkdir -p $sim_out

# use Baypass R function to simulate data....
cd $sim_out
Rscript $baypass_simulate --omega $omega \
			--beta $beta \
			--baypass $input_file \
			--Rfunctions $baypass_R \
			--suffix betapod

###
# 3. Rerun Baypass with simulated data to find XtX threshold above which we will consider sites outliers
###
echo "Running Baypass on simulated data..."

baypass -countdatafile $sim_out/G.betapod \
	-outprefix $sim_out/G.betapod \
	-nthreads 8

###
# 4. Use Baypass R function to calculate 1% threshold
###
echo "Calculating 1% threshold..."

Rscript $baypass_threshold --infile $sim_out/G.betapod_summary_pi_xtx.out \
			--out $sim_out/G.betapod_threshold.txt


###
# 5. Filter Baypass output for outlier SNPs
###
echo "Filtering Baypass output for outlier SNPs..."

# Use the value stored in G.betapod_threshold.txt to filter Baypass output for outlier SNPs
thresh=$(cat $sim_out/G.betapod_threshold.txt)
awk -v t="$thresh" '$4 > t' \
	$baypass/${SET}_summary_pi_xtx.out \
	> $baypass/${SET}_baypass_outliers.txt

# Finally, match the outliers with their SNP IDs
(
  # Print the first header line, add SNPID column
  head -n 1 "$baypass/${SET}_baypass_outliers.txt" | awk '{print $0, "SNPID"}'
  
  # Then skip the first line (header) and any other lines matching header text, print rest with SNPID appended
  awk 'FNR==NR {snp[$4]=$3; next}
       NR>1 && $1 != "MRK" {print $0, snp[$1]}' \
    "$baypass/${PROJECT}_snp_ids.txt" \
    "$baypass/${SET}_baypass_outliers.txt"
) > "$baypass/${SET}_baypass_outliers_SNPIDs.txt"



#Cores: 8
#Tasks: 1
#Nodes: 1
#Job Wall-time:   20.8%  05:00:03 of 1-00:00:00 time limit
#CPU Efficiency:  92.5%  1-12:59:23 of 1-16:00:24 core-walltime
#Mem Efficiency:   7.0%  1.12 GB of 16.00 GB
