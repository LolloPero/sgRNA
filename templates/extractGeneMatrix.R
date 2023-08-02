#!/usr/bin/env Rscript


########################################################################################
# HEADER                                  #
#########################################################################################
# '''
# Script for getting TCGA gene expression matrix of 2 pre-defined  TCGA samples.
# The genes in the expression matrix are limited to those present in the input bedfile 
# '''



########################################################################################################################
## Load packages
########################################################################################################################

packages <- c(
  "data.table",
  "TCGAbiolinks",
  "SummarizedExperiment",
  "org.Hs.eg.db",
  "stringr",
  "optparse"
)


for (p in packages) {
  suppressPackageStartupMessages(library(p, character.only = TRUE))
}


########################################################################################################################
## Parse arguments
########################################################################################################################

option_list <- list(

  make_option("--input", action = "store", type = "character",
              default = NA,
              help="Input bedfile with relevant gene names."),

  make_option("--output", action = "store", type = "character",
              default = NA,
              help="TCGA gene-expression matrix of gene names in input bedfile")

)

parser <- optparse::OptionParser(option_list=option_list)
args <- optparse::parse_args(parser)

if (any(is.na(args))) {
  optparse::print_help(parser)
  missing_args <- names(args[is.na(args)])
  stop(sprintf("The following arguments are mandatory: '%s'", paste(missing_args, collapse = "', '")))
}



########################################################################################################################
## Helper functions
########################################################################################################################

get_tcgaBiolinks <- function(input_samples){

    # query platform Illumina HiSeq with a list of barcode 
  query <- GDCquery(
  project = "TCGA-BRCA", 
  data.category = "Transcriptome Profiling",
  data.type = "Gene Expression Quantification",
  workflow.type = "STAR - Counts",
  barcode = input_samples
)

# download a list of barcodes with platform IlluminaHiSeq_RNASeqV2
GDCdownload(query)

# prepare expression matrix with geneID in the rows and samples (barcode) in the columns
BRCA.Rnaseq.SE <- GDCprepare(query)
BRCAMatrix <- assay(BRCA.Rnaseq.SE,"unstranded") 

BRCAMatrix.df <- as.data.frame(BRCAMatrix)

return(BRCAMatrix.df)

}


########################################################################################################################
## Import and Initialization section
########################################################################################################################

#read input bed file
bed_file <- data.table::fread(args$input, sep='\t')

# Define TCGA barcodes of samples to download.
listSamples <- c(
  "TCGA-A7-A13D-01A-13R-A12P-07",
  "TCGA-E9-A1RH-11A-34R-A169-07"
)


########################################################################################################################
## Computation section
########################################################################################################################

#extract Genes of Interest (goi) from Bed file
gene_col <- unname(sapply(bed_file$V7, function(x) unlist(strsplit(x, ";"))[1])) 
goi <- unique(na.omit(gene_col))


# get TCGA-BIOLINK data matrix ----
BRCAMatrix.df <- get_tcgaBiolinks(listSamples)


#convert ENSEMBL IDS to GENE Symbols
rownames(BRCAMatrix.df) <- 
str_replace(rownames(BRCAMatrix.df),
                       pattern = ".[0-9]+$",
                       replacement = "")

BRCAMatrix.df$symbol <- mapIds(org.Hs.eg.db, keys = rownames(BRCAMatrix.df), keytype = "ENSEMBL", column = "SYMBOL")
BRCAMatrix.df <- BRCAMatrix.df[, c(c("symbol"), listSamples)]

#subset BRCA matrix with goi
BRCAMatrix.df.goi <- subset(BRCAMatrix.df, BRCAMatrix.df$symbol %in% goi)

## Write results to output
write.table(BRCAMatrix.df.goi, file = args$output, sep = '\t', quote = FALSE, row.names = FALSE)