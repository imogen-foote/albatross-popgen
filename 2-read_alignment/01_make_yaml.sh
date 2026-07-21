#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=20MB
#SBATCH --time=0-0:05:00
#SBATCH --job-name=make_yaml
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## Script to generate BAM pipeline makefile for Paleomix

# Set paths
read_dir=/path/to/raw_data/illumina
output_dir=/path/to/out/paleomix
mkdir -p $output_dir

# Blank makefile can be generated using
# paleomix bam_pipeline makefile
# this needs to be edited to make sure all parameters are correctly set and the lines pointing to the reference genome and library directories are correct

# Use for loop to create a new directory with sample basename, copy the blank makefile and edit read path file with sample name
for f in $read_dir/*_R1.fastq.gz ; do
  base=$(basename ${f%_H*})

  mkdir $output_dir/$base
  cp /path/to/blank.yaml $output_dir/$base/$base.yaml
  sed -i "s/xxsamplexx/${base}/g" $output_dir/$base/$base.yaml
done 

## NOTE: makefiles had to be manually edited afterwards for a small number of samples that had multiple libraries  

