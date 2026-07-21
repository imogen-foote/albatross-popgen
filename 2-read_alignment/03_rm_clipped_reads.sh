#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH -a 1-86
#SBATCH --mem=30G
#SBATCH --time=1:30:00
#SBATCH --job-name=rm_clipped
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to identify and remove soft-clipped reads from alignment

# Load modules
module purge
module load SAMtools/1.16.1-GCC-11.3.0

# Set paths
N=${SLURM_ARRAY_TASK_ID}
sample_list=/path/to/resources/paleomix/samples.txt         # A txt file with list of sample names each on separate line
sample=$( head -n $N $sample_list | tail -n 1 | cut -f 1 )  # Set sample name by extract Nth sample from sample list, according to array N
REF=$1                                                      # reference genome name
read_dir=/path/to/data/paleomix/${sample}


# Create list of all clipped reads
samtools view $read_dir/$sample'_1.0.'$REF'_nuclear.bam' |awk '$6 ~ /H|S/ {print $1}' |sort -u > $read_dir/$sample'_clipped_reads_list.txt'

# Filter clipped reads
samtools view -h $read_dir/$sample'_1.0.'$REF'_nuclear.bam' | fgrep -wvf $read_dir/$sample'_clipped_reads_list.txt' | samtools view -b - -o $read_dir/$sample'_1.0.'$REF'_nuclear_clipped.bam'

# Create index for new bam file
samtools index $read_dir/$sample'_1.0.'$REF'_nuclear_clipped.bam'

