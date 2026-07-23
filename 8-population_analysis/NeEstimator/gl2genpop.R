rm(list=ls())

library(vcfR)
library(dartR)
library(tidyverse)

# -----------------------------
# INPUTS
# -----------------------------

vcf_file <- "/path/to/neutralsnps/neutral_subset.vcf.gz"

outdir <- "/path/to/out/NeEstimator"

sample_info <- read_tsv(
  "/path/to/pop_info.tsv"
)

dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

# -----------------------------
# LOAD VCF
# -----------------------------

vcf <- read.vcfR(vcf_file)

gl <- vcfR2genlight(vcf)

# -----------------------------
# ASSIGN POPS
# -----------------------------

sample_info <- sample_info[
  match(indNames(gl), sample_info$IND),
]

stopifnot(all(indNames(gl) == sample_info$IND))

pop(gl) <- factor(sample_info$POP)

print(table(pop(gl)))

# -----------------------------
# OPTIONAL CLEANING (recommended)
# -----------------------------

gl <- gl.filter.monomorphs(gl)


# -----------------------------
# WRITE GENEPOP
# -----------------------------

gl2genepop(
  gl,
  outfile = "AllAlbatross.gen",
  outpath = outdir
)

cat("Genepop written to:", outdir, "\n")


