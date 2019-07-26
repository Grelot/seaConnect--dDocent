## create barcodes file for each run
SPECIES=$1

for fastqf in `awk 'NR>1 { print $1 }' 01-infos/"${SPECIES}"_sample_information.tsv | sort | uniq`
do
	grep $fastqf 01-infos/"${SPECIES}"_sample_information.tsv | awk '{ print $2}' > 01-infos/barcodes/"${fastqf}".txt
done

