## create barcodes file for each run
SPECIES=$1

for fastqf in `awk 'NR>1 { print $1 }' 01-infos/"${SPECIES}"_sample_information.csv | sort | uniq`
do
	grep $fastqf 01-infos/"${SPECIES}"_sample_information.csv | awk '{ print $2}' > 01-infos/barcodes/"${fastqf}".txt
done

