## species to process

SPECIES=$1
SPECIES=mullus


## dDocent
CONTAINER=/entrepot/working/seaconnect/seaConnect--dDocent/seaconnect.simg
DDOCENT_CONFIG=/entrepot/working/seaconnect/seaConnect--dDocent/01-infos/ddocent_config.file


#### run the workflow "dDocent"
cd 04-ddocent/"${SPECIES}"/
singularity exec -B "/entrepot:/entrepot" $CONTAINER dDocent $DDOCENT_CONFIG
cd ../../
