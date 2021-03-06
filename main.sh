#########################################################################
### set global variables

## species to process

#SPECIES=$1
SPECIES=mullus
#SPECIES=diplodus

## dDocent
CONTAINER=/entrepot/working/seaconnect/seaConnect--dDocent/seaconnect.simg
DDOCENT_CONFIG=/entrepot/working/seaconnect/seaConnect--dDocent/01-infos/ddocent_config.file
CONTAINER=/media/bigvol/eboulanger/seaconnect/seaconnect.simg
DDOCENT_CONFIG=/media/bigvol/eboulanger/seaconnect/01-infos/ddocent_config.file
#########################################################################
### RUN THE WORKFLOW

### create barcode files
bash 00-scripts barcodes.sh "${SPECIES}"
## demultiplexing
#### mullus surmuletus
snakemake -s 00-scripts/snakeFile.process_radtags -j 8 --use-singularity --configfile 01-infos/config_"${SPECIES}".yaml --singularity-args "-B /entrepot:/entrepot"

## clean
#rm -Rf 03-samples/* 10-logs/*


## DEmultiplexing MOnitoring Report Tool
bash 00-script/demort.sh "${SPECIES}" "${CONTAINER}"

## rename
#bash 00-scripts/rename.sh "${SPECIES}" 01-infos/"${SPECIES}"_sample_information.tsv
#### with blacklist
bash 00-scripts/rename.sh "${SPECIES}" 01-infos/"${SPECIES}"_sample_information.tsv 98-metrics/"${SPECIES}"_samples_blacklist.txt


#### add a reference genome fasta file to ddocent folder
ln -s /entrepot/donnees/genomes/"${SPECIES}"_genome.fasta 04-ddocent/"${SPECIES}"/reference.fasta
#### run the workflow "dDocent"
bash 00-scripts/ddocent.sh "${SPECIES}" "${CONTAINER}" "${DDOCENT_CONFIG}"

##filter remove indels
#vcftools --vcf 04-ddocent/"${SPECIES}"/TotalRawSNPs.vcf --remove-indels --recode-INFO-all --recode --out 05-vcf/"${SPECIES}"_snps &>10-logs/vcftools_"${SPECIES}".log
bash 00-scripts/rm_indels.sh "${SPECIES}" "${CONTAINER}"

#########################################################################

