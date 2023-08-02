#!/bin/bash

# Define the URLs for the reference genome and genome annotation files
REFERENCE_GENOME_URL="https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set_maskedGRC_exclusions.fasta.gz"
GENOME_ANNOTATION_URL="https://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Homo_sapiens/all_assembly_versions/GCF_000001405.40_GRCh38.p14/GRCh38_major_release_seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation.gtf.gz"


# Download the reference genome and genome annotation to the mounted "resources" folder
wget -P /app/resources $REFERENCE_GENOME_URL && \
gzip -d /app/resources/GCA_000001405.15_GRCh38_no_alt_analysis_set_maskedGRC_exclusions.fasta.gz

wget -P /app/resources $GENOME_ANNOTATION_URL && \
gzip -d /app/resources/GCA_000001405.15_GRCh38_full_analysis_set.refseq_annotation.gtf.gz


#Compile genome index for STAR aligner
mkdir -p /app/resources/star
STAR  --runMode genomeGenerate  --runThreadN 3  --genomeDir /app/resources/star  --genomeFastaFiles /app/resources/GCA_000001405.15_GRCh38_no_alt_analysis_set_maskedGRC_exclusions.fasta 