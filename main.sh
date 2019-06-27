### demultiplexing
process_radtags -i gzfastq -P -p {input} -o {output} \
-b 01-info_files/barcodes.txt -c -r -t {params.trim_length} \
--adapter_mm {params.adapter_mm} --adapter_1 {params.adapter_1} \
--adapter_2 {params.adapter_2} --barcode_dist_1 {params.barcode_dist_1} \
--barcode_dist_2 {params.barcode_dist_2} -w {params.windows_size} \
-s {params.score_limit} -E {params.encoded} -e {params.enzyme} 2> {log}
### clone filter
mkdir -p {output}
for p in `ls {input}/*fq.gz | grep -v *rem* | cut -d "." -f 1 | sort | uniq`
do clone_filter -1 "$p".1.fq.gz -2 "$p".2.fq.gz -i gzfastq -o {output} 2> {log}
done
### rename file
### /!\ ind.R1.fq.gz et ind.F.fq.gz (forward backward) editer le code
bash ./00-scripts/rename_files.sh {output} {input.infos}
### attribute genome
ln -s 08-genomes/genome_sar.fasta 04-all/reference.fasta
### run dDocent
cd 04-all
dDocent 01-infos/ddocent_config.file
cd ..
##filter remove indels, keep only less 0.05 missing data genotype
##keep alternative allele frequencies more than 0.05 total and quality > 30
vcftools --vcf 04-all/TotalRawSNPs.vcf --remove-indels --max-missing 0.97 \
--maf 0.05 --out 05-vcf/Perfect --recode --non-ref-af 0.05 --max-missing 0.9 \
--max-non-ref-af 0.9999 --mac 1 --minQ 30 \
--recode-INFO-all &>10-logs/VCFtools_perfect.log
##output of vcftools is called Perfect.recode.vcf
##check missing data per INDIVIDUALS
vcftools --vcf 05-vcf/Perfect.recode.vcf --missing-indv
## see individuals with less than 10% missingness
awk '$5<0.1 {print $1}' 05-vcf/out.imiss

#convertir avec PGDSpider de vcf to STRUCTURE
path_to_pgdspider="/home/pguerin/src/PGDSpider_2.1.1.3/PGDSpider2-cli.jar"
pgdspider="java -Xmx1024m -Xms512m -jar "$path_to_pgdspider
vcf_a_convertir="05-vcf/Perfect.recode.vcf"
structure_output="06-structure/spider.structure"
spid_path="01-infos/ddocent2.spid"

$pgdspider -inputfile $vcf_a_convertir -outputfile $structure_output -inputformat VCF -outputformat STRUCTURE -spid $spid_path
##convertir le fichier structure en un fichier structure VRAIMENT READABLE par le software STRUCTURE
fichier_structure="06-structure/spider.structure"
final_structure_output="06-structure/propre.structure"
awk '{print $1","$2}' $fichier_structure | while read i ; do echo $i | cut -d "," -f 1 | cut -d "_" -f 1 | sed 's/C//g'; done | tail -n +2 > colonne
cat <(echo pop) colonne > colonne_h
awk '{ $1=""; $2=""; print $0 }' $fichier_structure > colsnps
#nombre d'individus
fichier_structure_nline=`wc -l 06-structure/spider.structure | awk '{ print $1}'`
END=`expr $fichier_structure_nline / 2`
for i in $(seq 1 $END); do echo $i; echo $i; done > colsample
cat <(echo sample) colsample > colsample_h
paste colsample_h colonne_h colsnps > temp.structure
#nombre de loci
END=`awk '{print NF}' 06-structure/spider.structure | uniq | head -1`
seq -s " " 1 $END > first_line
cat first_line <(tail -n +2 temp.structure) > $final_structure_output
rm colonne colonne_h colsnps colsample colsample_h temp.structure first_line

###run structure in parallel 4 POP 12 REPETITIONS
bash 00-scripts/parallel_structure.sh 4 12

## HARVESTER
struc_results="/data/pguerin/working/seaconnect_mullus/run_struc/final/struc_results"
mkdir $struc_results
mv results_K*f $struc_results
harvest_results="/data/pguerin/working/seaconnect_mullus/run_struc/final/str_harverster"
mkdir $harvest_results
cd /data/pguerin/src/structureHarvester/
python2 structureHarvester.py --dir="$struc_results" --out="$harvest_results" --evanno --clumpp
cd -
## CLUMPP
mkdir str_clumpp
cp str_harverster/K2.* str_clumpp/
cp ../STRUCTURE_ddocent3/str_clumpp_K2/paramfile str_clumpp/
number_indv=`awk '{ print $1}'  str_harverster/K2.indfile | sort | uniq | tail -n +2 | wc -l`
number_repet=`awk '{ print $1}'  str_harverster/K2.indfile | grep "^$" | wc -l`
sed 's/DATATYPE 1/DATATYPE 0/g' str_clumpp/paramfile | sed -e "s/^C [0-9]*/C ${number_indv}/g" | sed -e "s/^R [0-9]*/R ${number_repet}/g" > str_clumpp/p    aramfile_0
number_pop=`awk '{ print $1}'  str_harverster/K2.popfile | sort | uniq | tail -n +2 | wc -l`
number_repet=`awk '{ print $1}'  str_harverster/K2.popfile | grep "^$" | wc -l`
sed -e "s/^C [0-9]*/C ${number_pop}/g" str_clumpp/paramfile | sed -e "s/^R [0-9]*/R ${number_repet}/g" > str_clumpp/paramfile_1
cd str_clumpp
rm paramfile
cp paramfile_1 paramfile
echo "clumpp populations..."
CLUMPP
mv sar_K2.outfile sarsea.popq
rm paramfile
cp paramfile_0 paramfile
echo "clumpp individuals..."
CLUMPP
mv sar_K2.outfile sarsea.indivq
## geolocation of each individual and inference genetic pop associated
CLUMP_RES="sarsea.indvq"
GEO_LOCAL="01-infos/geolocation_sample_pop_seaconnect2_sar.txt"
python2 00-scripts/locate_individual_structure.py -c $CLUMP_RES -g $GEO_LOCAL > 07-geolocation/sarsea_geostr.txt
### figures genetic population map selon le tableau (arg1) et le prefix des pdf (arg2)
##/!\ il faut ajouter la gestion d'arguments dans le script genetic_pop_map_K2.R
Rscript 00-scripts/genetic_pop_map_K2.R 07-geolocation/sarsea_geostr.txt 11-figures/mullus_ITER1

### si la figure n'est pas satisfaisante (pas de structure geo visible)
#### on prepare une seconde iteration en retirant les individus de la deuxieme population
##total number of sample
numbSamp=`tail -1 07-geolocation/sarsea_geostr.txt | awk '{print $1}'`
#list des numbSamp id de samples
awk '{ print $1}' 06-structure/propre.structure | tail -n +2 | uniq > list_$numbSamp
seq 1 $numbSamp > colonne_$numbSamp
paste colonne_$numbSamp list_$numbSamp > tout_$numbSamp
#list des samples de la population a enlever
awk '{if( $4 < 0.6) print $1}' sarsea_geostr.txt |tail -n +2 > list_a_remove
#liste des samples a garder
grep -vwf list_a_remove tout_$numbSamp | awk '{ print $2}' > namelist
# liste des samples a retirer
grep -wf list_a_remove tout_$numbSamp | awk '{ print $2}' > liste_a_retirer
#ecrire le nouveau fichier structure
grep -wvf liste_a_retirer 06-structure/propre.structure > 06-structure/iter2.structure



