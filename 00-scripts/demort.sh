## species
#SPECIES=$1

## first argument is species name
SPECIES=$1
## second argument is container absolute path (optional)
CONTAINER=$2

## you can run demort.py without container (if it's already installed on your computer)
## the script detects if you provided a container or not

## DEmultiplexing MOnitoring Report Tool
if [ -z "$CONTAINER" ]
then
	## no singularity container
    demort.py -t 16 -d 01-infos/"${SPECIES}"_folders.txt -o 98-metrics/"${SPECIES}"_samples.csv -p 98-metrics/"${SPECIES}"_samples.pdf
else
	## use singularity container
    singularity exec "${CONTAINER}" demort.py -t 16 -d 01-infos/"${SPECIES}"_folders.txt -o 98-metrics/"${SPECIES}"_samples.csv -p 98-metrics/"${SPECIES}"_samples.pdf
fi



## blacklisting individuals with low number of reads
awk -F, '$3+0 < 950500 {print $0}' 98-metrics/"${SPECIES}"_samples.csv > 98-metrics/"${SPECIES}"_samples_blacklist.txt
