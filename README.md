# sgRNA
Simple Nextflow pipeline on sgRNA sequence

# Overview
This repository hosts a Nextflow pipeline which takes a sgRNA fasta file as input, an performs 4 steps:
- *alignToReference*: aligns the input sgRNA sequence to GrCh38 using STAR aligner 
- *bamToBed*:         converts the produced sam file to a bed file, to provide alignment information for each sequence in the input fasta file
- *compareGenes*:     produce a bed file to compare the gene name in each input sequence name to the gene name resulting from the alignment 
- *extractGeneMatrix*: produces a gene expression matrix of 2 TCGA-BRCA samples, restricted to the gene names resulting from the alignment

The output of each NextFlow process can be found under the *output* folder:
```
[lorper@i-04-l0001 sgRna]$ tree output/
output/
├── alignToReference
│   └── Aligned.out.sam
├── bamToBed
│   └── Aligned.out.bed
├── compareGenes
│   └── Aligned.out.sorted.genes.bed
└── extractGeneMatrix
    └── GeneMatrix.tsv

```


# Environment Setup

## Docker images setup
The following assumes that *Docker* is already installed in the system. 

First off, resource files (Genome reference and Genome annotation) need to be put in place. From terminal, execute the following:

create docker image
```
cd docker/resource_downloader
docker build -t genome_data_downloader:1.0 .
```
run docker container - will take a long time
```
cd ../../
docker run -v $(pwd)/resources:/app/resources genome_data_downloader:1.0
```

Second, create the docker image containing the necessary softwares to run the Nextflow pipeline:
```
cd docker/workflow
docker build -t sgRNA_workflow:1.0 .
```

# Execute workflow
Finally, to execute the nextflow pipeline, simply run:
```
nextflow run sgRNA.nf --with-docker sgRNA_workflow:1.0
```


