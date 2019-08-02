## rename file from demultiplexing from barcode to indivudal tag
## name of the file will be compatible with dDocent workflow

#argument 1 : path of the results 04-all_samples/species
#argument 2 : info files
#argument 3 : blacklist

mkdir -p 04-ddocent/$1
awk 'NR>1 { print $1"\t"$2"\t"$3"\t"$4}' $2 | grep -v -f <( awk -F, '{ print $1"\t"$2}' $3 | sed 's/sample_//g') | while read LANE BARCODE POP SAMPLE ;
do
	FILE_SE=`ls $(pwd)/03-samples/$LANE | grep "sample_"$BARCODE".fq.gz"`
 	if [ -z "$FILE_SE" ]
	then
		echo $FILE_SE" is empty"
	else
		PATH_SE=$(pwd)/03-samples/$LANE/$FILE_SE
		SAMPLE_EDIT=`echo $SAMPLE | sed 's/_/i/g'`
		echo $PATH_SE
		ln -s $PATH_SE "04-ddocent/"$1"/"$POP"_"$SAMPLE_EDIT".F.fq.gz"
	fi
done