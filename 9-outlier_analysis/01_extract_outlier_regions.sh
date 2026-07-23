#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=500MB
#SBATCH --time=01:0:00
#SBATCH --job-name=identify_regions
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## This script extracts genes located within 10,000 bp of identified outlier snps

# Load modules
module purge
module load bedtools/2.27.1

# Set paths
data=/path/to/outlier/data
genome=/path/to/ref_genome.fasta
annot=/path/to/genome_annotation.gff3 #produced using GALBA in this instance
eggnog=/path/to/functional_annotation/AntipodeanAlbatross.emapper.annotations #produced using eggnog mapper in this instance
out=/path/to/out/outlier_genes
mkdir -p $out

###
# 1.  Create window by expanding 10,000 bp either side of each snp
###

# First, convert outlier file to .bed file (three columns; chrom, start and end - start and end will be the same for snps)
awk 'BEGIN{OFS="\t"}{print $1,$2,$2}' $data/AllAlbatross_2025_antipodeanref_746_overlapping_outliers.tsv > $data/746_outliers.bed

# Expand snp coordinates to include a window of distance specified by extra variable
window=10000
bedtools slop -b $window -i $data/746_outliers.bed -g $genome.fai > $out/snp_regions_expanded_$window.bed

###
# 2. Extract regions
###
# Extract transcript lines only from .gff3 file (prevents duplication in output) - maybe?
awk -F'\t' '$3=="mRNA" || $3=="transcript"' $annot > $out/transcripts_only.gff3

# Extract lines from .gff3 file that contain the snps
bedtools intersect -a $out/transcripts_only.gff3 -b $out/snp_regions_expanded_$window.bed -wa -wb > $out/snp_regions_$window.gff3

# Extract gff fields
awk -F'\t' 'BEGIN{OFS="\t"} $3=="gene" || $3=="mRNA" || $3=="transcript" {match($9, /ID=([^;]+)/, a); if (a[1] != "") print $1,$4,$5,$7,$11,a[1]
}' $out/snp_regions_$window.gff3 \
> $out/snp_regions_genes.tsv

###
# 3. Join with eggnog data
### 

# Prepare eggnog data for joining
awk -F'\t' 'BEGIN{OFS="\t"} $1 !~ /^#/ {
    print $1, $2, $8, $9, $10
}' $eggnog > $out/eggnog_clean.tsv

# Join data to create final annotation table
awk 'BEGIN{FS=OFS="\t"}
NR==FNR {ann[$1]=$0; next}
($6 in ann) {
    split(ann[$6], a, "\t");
    print $1,$2,$3,$4,$5,$6,a[2],a[3],a[4],a[5]
}' $out/eggnog_clean.tsv \
$out/snp_regions_genes.tsv \
> $out/snp_final_table.tsv
