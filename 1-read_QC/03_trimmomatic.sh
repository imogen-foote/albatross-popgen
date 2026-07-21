#!/bin/bash
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=6G
#SBATCH --time=2-1:00
#SBATCH --job-name=trimmomatic
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to trim Illumina sequencing adapters from raw Illumina data
# NOTE: the trimmed reads were not used for subsequent steps as the paleomix pipeline includes adapter trimming 
# however, we performed trimming and reran FastQC/MultiQC steps for QC purposes

# Path to executable
trimmomatic=/path/to/bin/trimmomatic-0.39.jar

# Set paths
read_dir=/path/to/raw_data/illumina
output_dir=/path/to/data/trimmomatic

## Run trimmomatic
# Use for loop as trimmomatic can only run on one file at a time
for f in $read_dir/*_R1.fastq.gz ; do
  base=$(basename ${f%_H*})
  
  java -jar $trimmomatic PE \
    -threads 12 -phred33 \
    ${f} $read_dir/${base}*_R2.fastq.gz \
    $output_dir/${base}.forward_paired.fq.gz $output_dir/${base}.forward_unpaired.fq.gz \
    $output_dir/${base}.reverse_paired.fq.gz $output_dir/${base}.reverse_unpaired.fq.gz \
    ILLUMINACLIP:/path/to/adapt_seq/NexteraPE-PE.fa:2:30:10
done

