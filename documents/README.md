---
editor_options: 
  markdown: 
    wrap: sentence
---

# mtDNA Variant Analysis Practical: Setup Guide

## 1. Install R and RStudio (IDE)

-   Download [R](https://cran.r-project.org/)
-   Download [RStudio](https://posit.co/download/rstudio-desktop/) (Desktop is sufficient)

## 2. Essential R Libraries

Run this in R:

`install.packages(c('BiocManager', 'rmarkdown', 'Rsubread', 'QuasR', 'ggplot2', 'data.table', 'aws.s3'))` `BiocManager::install('GenomicAlignments')`

For advanced analysis:

`BiocManager::install('VariantAnnotation')`

## 3. External Tools

-   Download and install [GATK 4.x+](https://gatk.broadinstitute.org/)
-   [Mutect2](https://gatk.broadinstitute.org/) is part of GATK (requires Java 8+)
-   Download human reference genome (GRCh38) FASTA: via [GATK resource bundle](https://gatk.broadinstitute.org/hc/en-us/articles/360035890811) or NCBI

## 4. Data Preparation

-   Download human FASTQ files
-   Download reference genome [GRCh38.p14](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.29_GRCh38.p14/GCA_000001405.29_GRCh38.p14_genomic.fna.gz)

## 5. Workflow Overview

-   Obtain data: Download human raw FASTQ and reference files.
-   Install tools: Set up R, RStudio, and required R/Bioconductor packages.
-   Align reads: Map FASTQ to the reference genome using Rsubread or QuasR.
-   Quality control and reporting: Visualize and summarize coverage, check mapping statistics.
-   Variant calling and downstream: Outline or trigger Mutect2 (or use finished MitoHPC pipeline).
-   Interpret results: Explore detected variants, heteroplasmy, and biological meaning.

## 6. How to Run the Provided R Markdown Notebook

-   Open `alignment_and_variant_calling.Rmd` in RStudio.
-   Read through "Introduction" for biological background and step logic.
-   Run each code chunk in order (Ctrl+Shift+Enter) and follow the output and commentary.
-   Plots and tables will appear inline; results can be saved or rendered to HTML.
-   For variant calling, you may need to run a system command (see instructions, e.g., Mutect2) if BAM files are too large to handle in R. Results can be loaded back into R for summary and visualization.
