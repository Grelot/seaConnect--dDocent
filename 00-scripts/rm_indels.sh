## remove INDEL variants from raw dDocent's output VCF file 

SPECIES=$1
CONTAINER=$2

singularity exec "${CONTAINER}" vcftools --vcf 04-ddocent/"${SPECIES}"/Final.recode.vcf --remove-indels --recode --recode-INFO-all --out 05-vcf/"${SPECIES}"