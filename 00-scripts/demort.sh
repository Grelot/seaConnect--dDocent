## species
#SPECIES=$1
SPECIES=mullus



## DEmultiplexing MOnitoring Report Tool
demort.py -t 16 -d 01-infos/"${SPECIES}"_folders.txt -o 98-metrics/"${SPECIES}"_samples.csv -p 98-metrics/"${SPECIES}"_samples.pdf

## blacklisting individuals with low number of reads
awk -F, '$3+0 < 950500 {print $0}' 98-metrics/"${SPECIES}"_samples.csv > 98-metrics/"${SPECIES}"_samples_blacklist.txt
