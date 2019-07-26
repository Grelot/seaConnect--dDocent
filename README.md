# DDOCENT FOR SEACONNECT

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![Snakemake](https://img.shields.io/badge/snakemake-5.5.2-brightgreen.svg)](https://snakemake.bitbucket.io)

Process Genotypage by Sequencing data with low coverage using a dDocent-based workflow. We performed this workflow as part of the [SEACONNECT project](https://reefish.umontpellier.fr/index.php?article9/total-seaconnect) on 900 samples among 2 fish species _mullus Surmuletus_ and _diplodus Sargus_ in Mediterranean sea.

# INSTALLATION

You can get the development version of the code by cloning this repository:

```
git clone https://github.com/Grelot/seaConnect--dDocent.git
```
## Prerequisites

* bash (linux OS ubuntu xenial)
* [singularity](https://github.com/sylabs/singularity)
* [snakemake](https://snakemake.bitbucket.io)

## Dependencies
You will need to have the following programs installed on your computer.

- OSX or GNU Linux
- bash 4.4.19
- SINGULARITY 2.4.2-dist
- curl 7.47.0
- Python 2.7.12
- CD-HIT 4.6
- samtools 1.3.1
- bedtools 2.26.0
- PEAR 0.9.11
- fastp 0.20.0
- STACKS 1.48
- dDocent 2.7.6
- VCFtools 0.1.14
- Trimmomatic 0.33
- JAVA 8.0
- freebayes 1.3.1
- GNUPLOT 5.0
- MAWK 1.2
- rainbow 2.0.4
- GNU parallel
- seqtk 1.0
- BWA 0.7.17

## Singularity

See https://www.sylabs.io/docs/ for instructions to install Singularity.

We provide a [Singularity recipe](Singularity.seaconnect) and ready to run container with all required dependencies.

### Build a container
Build a local container with all required programs and dependencies using Singularity recipe [Singularity.seaconnect](Singularity.seaconnect)

```
sudo singularity build seaconnect.simg Singularity.seaconnect
```

### Download a container
Pull a ready to run version of Singularity container

```
singularity pull --name seaconnect.simg shub://Grelot/............................;
```


# RUN THE WORKFLOW

## Preprocessing

First, SINGLE-END `fastq` files must be quality-filtered.
We provide a complete workflow to perform preprocessing of sequencing ngs raw data. This workflow is available as a github repositories here : [clean-fastq](https://github.com/Grelot/clean-fastq)


## Set up

### Wildcards
* `{species}` : any complete project (in our case we have 2 projects : mullus and diplodus)
* `{lane}` : any physical lane on a flow cell that goes into the sequencing machine. We have many `{lane}` by `{species}`
* `{barcode}` : any DNA sequence attached to a reads which belong to a sample. We have many `{barcode}` by `{lane}` by `{species}`
* `{pop}` : any group of samples
* `{sample}` : any sample

### Container
The container (see [Singularity](#singularity) section below) must be stored into the main directory of this project [seaConnect--dDocent](.) with the name `seaconnect.simg`

### cleaned fastq data

Write the absolute path of the folder containing filtered data after [preprocessing](#-preprocessing) into [config.yaml](01-infos/config_mullus.yaml) `fastq` section `folder` subsection. Prefix of each fastq file you want to process must be write as a list into subsection `file`

**For instance :**

Each fastq file into my filtered folder is a `{lane}` :

```
ls /entrepot/donnees/seaconnect/gbs_mullus/cleaned/
C6JATANXX_2.i.p.q.fastq.gz  C6JATANXX_5.i.p.q.fastq.gz 
C6JATANXX_3.i.p.q.fastq.gz  C6JATANXX_6.i.p.q.fastq.gz
C6JATANXX_4.i.p.q.fastq.gz  C8BJGANXX_1.i.p.q.fastq.gz
```

I write the fastq file to process into [config.yaml](01-infos/config_mullus.yaml) this way :
```
fastq:
    folder: /entrepot/donnees/seaconnect/gbs_mullus/cleaned
    file:
        - C6JATANXX_5
        - C6JATANXX_6
        - C8BJGANXX_1
        - C6JATANXX_4
        - C6JATANXX_3
        - C6JATANXX_2
```


### sample information

For each `{species}`, we provide a `sample information file`.
It must be stored as `01-infos/{species}_sample_information.tsv`.
(for instance we provide [mullus_sample_information.tsv](01-infos/mullus_sample_information.tsv))  
This first 4 colons must be :
```
{lane}	{barcode}	{pop}	{sample}	...
```
:warning: Your file `01-infos/{species}_sample_information.tsv` must have a header. (The first line of this file is skipped by the program)


## barcodes

We create a `barcode file` for each `{lane}` which contains a list of the `{barcode}` present into the give `{lane}`.

```
bash 00-scripts barcodes.sh {species}
```
This command will create a `barcode` file such as `01-infos/barcodes/{lane}.txt` for each `{lane}`

## Demultiplexing

Demultiplexing refers to the step in processing where you’d use the `{barcode}` information in order to know which sequences came from which `{sample}` after they had all be sequenced together. Barcodes refer to the unique sequences `{barcode}` that were ligated to each of your invidivual samples genetic material `{sample}` before the samples got all mixed together. 

Samples are lumped together all in one fastq file with barcodes still attached. We use a `barcode file` to split fastq file sequences by `{barcode}`


We use [snakemake](https://snakemake.bitbucket.io) workflow managment system for this step.

We use [process_radtags](http://catchenlab.life.illinois.edu/stacks/comp/process_radtags.php) from [STACKS 1.48](http://catchenlab.life.illinois.edu/stacks/) to perform demultiplexing. Parameters can be set into [config.yaml](01-infos/config_mullus.yaml) `process_radtags` section.


```
snakemake -s 00-scripts/snakeFile.process_radtags -j 8 --use-singularity --configfile 01-infos/config_mullus.yaml --singularity-args "-B /entrepot:/entrepot"
```
This command process demultiplexing for each `{lane}`. Results are stored into `03-samples/{lane}/sample_{barcode}.fq.gz`

:warning: If your cleaned fastq data folder is not into the current directory, you have to create a binding point for the singularity container. Modify the `--singularity-args "-B /entrepot:/entrepot"` argument of the command below.

## Mapping `{barcode}` with `{pop}` and `{sample}`

Each fastq file belonging to a specific `{barcode}` is renamed by the corresponding association `{pop}` and `{sample}` as stipulated into `{species}_sample_information.tsv` file. (see for instance [mullus_sample_information.tsv](01-infos/mullus_sample_information.tsv))

```
bash 00-scripts/rename.sh {species} 01-infos/{species}_sample_information.csv
```

This command create a symlink of all fastq files such as `03-samples/{lane}/sample_{barcode}.fq.gz` is linked by `04-renamed/{species}/{pop}_{sample}.F.fq.gz`.

## dDocent workflow


[dDocent](https://www.ddocent.com/) is simple bash wrapper to QC, assemble, map, and call SNPs from almost any kind of RAD sequencing. If you have a reference already, dDocent can be used to call SNPs from almost any type of NGS data set.

1. dDocent performs a quality control of input sequences
2. dDocent aligns sequences against a `{species}` reference genome sequence.
3. dDocent performs a quality control of alignments
4. Bayesian, haplotype based, population-aware, genotyping from FreeBayes.

FreeBayes is a Bayesian genetic variant detector designed to detect SNPs, INDels (insertions and deletions), and complex events (composite insertion and substitution events) smaller than the length of a short-read sequencing alignment. FreeBayes is haplotype-based, in the sense that it calls variants based on the literal sequences of reads aligned to a particular target, not their precise alignment, and for any number of individuals from a population and a to determine the most-likely combination of genotypes for the population at each position in the reference.



**run dDocent workflow :**

* Go into the `04-renamed/{species}` folder.
* Then add a `04-renamed/{species}/reference.fasta` genome reference sequence file.
* Now you can run the complete dDocent workflow. Type the following commands :

```
## global variable
CONTAINER=/entrepot/working/seaconnect/seaConnect--dDocent/seaconnect.simg
DDOCENT_CONFIG=/entrepot/working/seaconnect/seaConnect--dDocent/01-infos/ddocent_config.file
## run dDocent
singularity exec -B "/entrepot:/entrepot" $CONTAINER dDocent $DDOCENT_CONFIG
```

This command run dDocent workflow. It generates genotypes for each `{sample}` for each locus. These genotypes are stored into a `VCF` file.

:warning: path of CONTAINER and DDOCENT_CONFIG must be absolute and you have to create a binding point for the singularity container in order to access to these files. (see `-B "/entrepot:/entrepot"` argument)

## Generate final VCF

Genotypes are stored as `VCF` files. We keep only SNPs (Single Nucleotide Polymorphism) variants.