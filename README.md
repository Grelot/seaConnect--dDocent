# seaConnect--dDocent

[![Snakemake](https://img.shields.io/badge/snakemake-5.5.2-brightgreen.svg)](https://snakemake.bitbucket.io)

Process Genotypage by Sequencing data for 2 species with low coverage using a dDocent-based pipeline

# Installation

You can get the development version of the code by cloning this repository:

```
git clone https://github.com/Grelot/seaConnect--dDocent.git
```

## Depencies
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
- STACKS 2.4
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

We provide a [Singularity recipe](Singularity.seaconnect) and ready to run container with all dependencies.

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
