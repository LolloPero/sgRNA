# Use the Ubuntu 23.10 base image
FROM ubuntu:23.10

# Update package list and install necessary dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gzip \
    build-essential \
    r-base=4.0.0*

# Install STAR
RUN wget https://github.com/alexdobin/STAR/archive/2.7.10b.tar.gz && \
    tar -xzf 2.7.10b.tar.gz && \
    rm 2.7.10b.tar.gz && \
    cd STAR-2.7.10b/source && \
    make STAR && \
    mv STAR /usr/local/bin

# Install Bedtools
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools-2.30.0.tar.gz && \
    tar -zxvf bedtools-2.30.0.tar.gz && \
    rm bedtools-2.30.0.tar.gz && \
    cd bedtools2 && \
    make && \
    mv bin/* /usr/local/bin

# Install Bedops
RUN wget https://github.com/bedops/bedops/releases/download/v2.4.40/bedops_linux_x86_64-v2.4.40.tar.bz2 && \
    tar -xjf bedops_linux_x86_64-v2.4.40.tar.bz2 && \
    rm bedops_linux_x86_64-v2.4.40.tar.bz2 && \
    mv bin/* /usr/local/bin

# Install R packages and Bioconductor packages
RUN R -e 'install.packages(c("BiocManager", "data.table", "stringr", "optparse"))' && \
    R -e 'BiocManager::install(c("org.Hs.eg.db", "TCGAbiolinks", "SummarizedExperiment"))'

# Set the entrypoint to start bash in the container
ENTRYPOINT ["/bin/bash"]
