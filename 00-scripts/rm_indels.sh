## remove INDEL variants from raw dDocent's output VCF file 

SPECIES=$1

singularity exec seaconnect.simg vcftools --vcf 04-ddocent/"${SPECIES}"/TotalRawSNPs.vcf --remove-indels --recode --recode-INFO-all --out 05-vcf/"${SPECIES}"