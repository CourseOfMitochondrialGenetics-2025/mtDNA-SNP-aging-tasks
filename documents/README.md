# mtDNA Variant Analysis Practical: Setup Guide

## 1. Install R and RStudio (IDE)
- Download [R](https://cran.r-project.org/)
- Download [RStudio](https://posit.co/download/rstudio-desktop/) (Desktop is sufficient)

## 2. Essential R Libraries

Run this in R:

`install.packages(c('BiocManager', 'rmarkdown', 'Rsubread', 'QuasR', 'ggplot2', 'data.table'))`
`BiocManager::install('GenomicAlignments')`

For advanced analysis:

`BiocManager::install('VariantAnnotation')`

## 3. External Tools
- Download and install [GATK 4.x+](https://gatk.broadinstitute.org/)
- [Mutect2](https://gatk.broadinstitute.org/) is part of GATK (requires Java 8+)
- Download human reference genome (GRCh38) FASTA: via [GATK resource bundle](https://gatk.broadinstitute.org/hc/en-us/articles/360035890811) or NCBI

## 4. Data Preparation
- Download human FASTQ files
- Download reference genome (https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.29_GRCh38.p14/GCA_000001405.29_GRCh38.p14_genomic.fna.gz
)
