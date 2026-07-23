#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=0-0:05:00
#SBATCH --job-name=vcf2ba3
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to convert neutral SNPs VCF to correct format to run BA3-SNPs
# NOTE: this script uses the subset neutral SNP dataset (~10,000 SNPs) due to memory requirements 

# Load modules
module purge
module load BCFtools/1.19-GCC-11.3.0
module load tabix/0.2.6-GCCcore-9.2.0

# Set paths
VCF=/path/to/neutralsnps/neutral_subset
pop_file=/path/to/pop_info.tsv # 2 column (IND POP) tab delimited file - make sure there is an empty line at the end or the last sample will get missed
out_dir=/path/to/out/ba3snps/neutral_subset
mkdir -p $out_dir

## Set paths to vcf2ba3 scripts
# requires scripts from https://github.com/brannala/ugnix.git
ba3=/path/to/ba3snpsscripts/ugnix/scripts
bcf2ba3=$ba3/bcf2ba3
poptrans=$ba3/poptrans

# Convert to ba3
$bcf2ba3 $VCF.vcf.gz > $out_dir/neutral_subset.ba3

# Add pop info
$poptrans $pop_file $out_dir/neutral_subset.ba3 > $out_dir/neutral_subset_withpops.ba3


#State: COMPLETED
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:    17.7%  00:00:53 of 00:05:00 time limit
#CPU Utilisation:  43.4%  00:00:45 of 00:01:46 core-walltime
#Mem Utilisation:   0.1%  1.43 MB of 1.00 GB
