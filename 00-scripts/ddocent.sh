## species to process

SPECIES=$1
SPECIES=mullus


## dDocent
CONTAINER=$2
DDOCENT_CONFIG=$3

#### run the workflow "dDocent"
cd 04-ddocent/"${SPECIES}"/
singularity exec -B "/entrepot:/entrepot" $CONTAINER dDocent $DDOCENT_CONFIG
cd ../../
