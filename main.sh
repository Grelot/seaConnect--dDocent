## species to process

#SPECIES=$1
SPECIES=mullus
#SPECIES=diplodus



### create barcode files
bash 00-scripts barcodes.sh "${SPECIES}"
## demultiplexing
#### mullus surmuletus
snakemake -s 00-scripts/snakeFile.process_radtags -j 8 --use-singularity --configfile 01-infos/config_"${SPECIES}".yaml --singularity-args "-B /entrepot:/entrepot"

## clean
#rm -Rf 03-samples/* 10-logs/*


## rename
bash 00-scripts/rename.sh "${SPECIES}" 01-infos/"${SPECIES}"_sample_information.csv

## dDocent
CONTAINER=/entrepot/working/seaconnect/seaConnect--dDocent/seaconnect.simg
DDOCENT_CONFIG=/entrepot/working/seaconnect/seaConnect--dDocent/01-infos/ddocent_config.file

#### add a reference
ln -s /entrepot/donnees/genomes/"${SPECIES}"_genome.fasta 04-renamed/"${SPECIES}"/reference.fasta
#### run the workflow "dDocent"
cd 04-renamed/"${SPECIES}"/
singularity exec -B "/entrepot:/entrepot" $CONTAINER dDocent $DDOCENT_CONFIG
cd ../../
##filter remove indels
vcftools --vcf 04-renamed/"${SPECIES}"/TotalRawSNPs.vcf --remove-indels --recode-INFO-all --recode --out 05-vcf/"${SPECIES}"_snps &>10-logs/vcftools_"${SPECIES}".log




#########################################################################

