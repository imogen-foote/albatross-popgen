#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=1-0:00:00
#SBATCH --job-name=pixy
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

# Load conda env (see pixy_environment.yaml for env specifics)
module purge
module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1
conda activate /nesi/project/vuw03922/pixy


# Set paths
read_dir=/path/to/allsitesvcf
pop_file=/path/to/pixy_popinfo.txt #2 column (IND POP) tab delimited population file WITHOUT HEADERS
out_dir=/path/to/out/allsites
mkdir -p $out_dir

# Run pixy 
pixy --stats pi dxy fst watterson_theta tajima_d \
    --vcf $read_dir/allsites.vcf.gz \
    --populations $pop_file \
    --window_size 25000 \
    --n_cores 2 \
    --output_folder $out_dir/pixy
#--version
#--chromosomes 'X' ##can use this option to just look at certain chromosomes, otherwise it will look at whole genome
# fst calculation defaults to weir & cockerham

conda deactivate


#State: COMPLETED
#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:    38.0%  18:13:02 of 2-00:00:00 time limit
#CPU Utilisation:  54.7%  19:54:45 of 1-12:26:04 core-walltime
#Mem Utilisation:  14.9%  305.54 MB of 2.00 GB
