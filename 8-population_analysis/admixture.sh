#!/bin/bash
#SBATCH --cpus-per-task=4
#SBATCH --mem=1G
#SBATCH --time=0-1:00:00
#SBATCH --job-name=admixture
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

# Load modules
module purge
module load R/4.3.1-gimkl-2022a
module load Miniconda3
source $(conda info --base)/etc/profile.d/conda.sh
export PYTHONNOUSERSITE=1

# Activate conda env (see admixture_environment.yaml for env specifics)
conda activate /nesi/project/vuw03922/admixture


# Set paths
read_dir=/path/to/neutralsnps
out_dir=/path/to/out/admixture
mkdir -p $out_dir


###
# 1. First run across a range of K to determine the best value of K (lowest cross-validation error value)
###
mkdir $out_dir/CV_check

for K in 1 2 3 4 5; do
admixture --cv ${read_dir}.bed $K | tee log${K}.out > $out_dir/CV_check/K${K}.out

mv *.P $out_dir/CV_check/
mv *.Q $out_dir/CV_check/
mv log* $out_dir/CV_check/

done

awk '/CV/ {print $3,$4}' $out_dir/CV_check/*out | cut -c 4,7-20 > $out_dir/CV_check/cv.error



###
# 2. Then run with appropriate value of K
###

K=2
admixture -C 10000 ${read_dir}.bed $K -j4 > $out_dir/K${K}.out

mv *.P $out_dir/
mv *.Q $out_dir/
mv log* $out_dir/

# Name pops correctly
paste <(cut -f 1-2 ${read_dir}.fam) $out_dir/$K.Q > $out_dir/named.$K.Q

conda deactivate

# Rscript
admixture_plot=/path/to/Rscripts/admixture_plot_K$K.R

# Create admixture plot 
Rscript $admixture_plot --Q $out_dir/named.$K.Q \
		--out $out_dir



#Cores: 2
#Tasks: 1
#Nodes: 1
#Job Wall-time:   81.1%  00:24:19 of 00:30:00 time limit
#CPU Efficiency: 198.7%  01:36:37 of 00:48:38 core-walltime
#Mem Efficiency:   0.6%  6.18 MB of 1.00 GB

