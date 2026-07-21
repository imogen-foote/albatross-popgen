#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=500MB
#SBATCH --time=1:30:00
#SBATCH --job-name=downsample
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to downsample individuals with higher sequencing coverage 

# Load modules
module purge
module load SAMtools/1.16.1-GCC-11.3.0

# Set paths
IND=$1  # Sample name to downsample
bam=/path/to/paleomix/$IND


# Calculate initial coverage
echo "calculating initial coverage stats..."
samtools depth $bam/*'_nuclear_clipped.bam' | awk '{sum += $3} END {print "Average Coverage: ", sum/NR}'

# Downsample 
echo "downsampling..."
samtools view -s 0.5 -b -o $bam/downsampled_nuclear_clipped.bam $bam/*'_nuclear_clipped.bam' 

# Index new bam file
echo "indexing downsampled bam..."
samtools index $bam/downsampled_nuclear_clipped.bam

# Verify coverage
echo "calculating post-downsampling coverage stats..."
samtools depth $bam/downsampled_nuclear_clipped.bam | awk '{sum += $3} END {print "Average Coverage: ", sum/NR}'



#State: COMPLETED
#Cores: 1
#Tasks: 1
#Nodes: 1
#Job Wall-time:   65.2%  00:58:43 of 01:30:00 time limit
#CPU Efficiency: 131.7%  01:17:20 of 00:58:43 core-walltime
#Mem Efficiency:   1.0%  9.87 MB of 1.00 GB

