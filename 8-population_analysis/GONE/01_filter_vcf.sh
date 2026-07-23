#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G
#SBATCH --time=0:15:00
#SBATCH --job-name=filter_vcf
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

## The purpose of this script is to exclude contigs with only a few snps as GONE can't use these and they will throw an error
# and filter vcf to create VCF per pop as programme assumes closed population

# Load modules
module load BCFtools/1.19-GCC-11.3.0
module load R/4.3.1-gimkl-2022a
module load PLINK/1.09b6.16

# Set paths
read_dir=/path/to/neutralsnps/neutral
#contigs=./contigs_to_include.txt
vcf2R=/path/to/Rscripts/vcf2Rinput.R
gds2plink=/path/to/Rscripts/gds2plink.R
pop_file=/path/to/pop_info.tsv # 2 column (IND POP) tab delimited population file

###
# 2. Define scaffolds to include
###
#scaffolds="antipodean_1,antipodean_2,antipodean_3,antipodean_4,antipodean_5,antipodean_6,antipodean_7,antipodean_8,antipodean_9,antipodean_10,antipodean_11,antipodean_12,antipodean_13,antipodean_14,antipodean_15,antipodean_16,antipodean_17,antipodean_18,antipodean_19,antipodean_20,antipodean_21,antipodean_22,antipodean_23,antipodean_24,antipodean_25,antipodean_26,antipodean_27,antipodean_28,antipodean_29,antipodean_30,antipodean_31,antipodean_32,antipodean_33,antipodean_34,antipodean_35,antipodean_36,antipodean_37,antipodean_38,antipodean_39,antipodean_40"
scaffolds="gibsons_1,gibsons_2,gibsons_3,gibsons_4,gibsons_5,gibsons_6,gibsons_7,gibsons_8,gibsons_9,gibsons_10,gibsons_11,gibsons_12,gibsons_13,gibsons_14,gibsons_15,gibsons_16,gibsons_17,gibsons_18,gibsons_19,gibsons_20,gibsons_21,gibsons_22,gibsons_23,gibsons_24,gibsons_25,gibsons_26,gibsons_27,gibsons_28,gibsons_29,gibsons_30,gibsons_31,gibsons_32,gibsons_33,gibsons_34,gibsons_35,gibsons_36,gibsons_37,gibsons_38,gibsons_39,gibsons_40"

###
# 2. filter to retain only antips and first 40 scaffolds
###
bcftools view -Oz -s ANT_DG46,ANT_DG47,ANT_DG48,ANT_DG49,ANT_DG50,ANT_MW16,ANT_MW17,ANT_MW18,ANT_MW19,ANT_MW21,ANT_MW22,ANT_MW24,ANT_NP28,ANT_NP30,ANT_NP31,ANT_NP32,ANT_NP33,ANT_NP34,ANT_NP35,ANT_NP36,ANT_NP39,ANT_NP40,ANT_NP41,ANT_NP42,ANT_NP43,ANT_NP44,ANT_OR01,ANT_OR02,ANT_OR03,ANT_OR04,ANT_OR05,ANT_OR06,ANT_OR07,ANT_OR08,ANT_OR10,ANT_OR11,ANT_OR13,ANT_OR14,ANT_OR15,ANT_SA51,ANT_SA52,ANT_SA53,ANT_SA54	\
	-r $scaffolds \
	-o ${read_dir}_antipodean.vcf.gz	\
	${read_dir}.vcf.gz	

###
# 3. Convert to correct file inputs 
###
# Convert VCF to gds
Rscript $vcf2R --gzvcf ${read_dir}_antipodean.vcf.gz \
               --snprelate_out ${read_dir}_antipodean

# Convert gds to plink
Rscript $gds2plink --gds_file ${read_dir}_antipodean.gds \
                   --out ${read_dir}_antipodean \
                   --pop_file $pop_file

# Make .ped and .map as well
plink --bfile ${read_dir}_antipodean --recode --out ${read_dir}_antipodean --chr-set 65	

###
# 4. Do the same for Gibson's
###
# Filter to retain only gibsons and first 40 scaffolds
bcftools view -Oz -s GIB_AA01,GIB_AA04,GIB_AA05,GIB_AA07,GIB_AA08,GIB_AA09,GIB_AA13,GIB_AA15,GIB_AA16,GIB_AA17,GIB_AA19,GIB_AA22,GIB_AA24,GIB_AA25,GIB_AA26,GIB_AA27,GIB_AA29,GIB_AA30,GIB_AA31,GIB_DI48,GIB_DI49,GIB_DI50,GIB_DI51,GIB_DI52,GIB_DI53,GIB_DI54,GIB_DI55,GIB_MD32,GIB_MD33,GIB_MD34,GIB_MD35,GIB_MD36,GIB_MD37,GIB_MD38,GIB_MD39,GIB_MD40,GIB_MD41,GIB_MD42,GIB_MD43,GIB_MD44,GIB_MR45,GIB_MR46,GIB_MR47	\
	-r $scaffolds \
	-o ${read_dir}_gibsons.vcf.gz	\
	${read_dir}.vcf.gz

# Convert VCF to gds
Rscript $vcf2R --gzvcf ${read_dir}_gibsons.vcf.gz \
               --snprelate_out ${read_dir}_gibsons

# Convert gds to plink
Rscript $gds2plink --gds_file ${read_dir}_gibsons.gds \
                   --out ${read_dir}_gibsons \
                   --pop_file $pop_file

# Make .ped and .map as well
plink --bfile ${read_dir}_gibsons --recode --out ${read_dir}_gibsons --chr-set 65	

