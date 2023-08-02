# Use a base image with the necessary dependencies (Ubuntu in this case)
FROM ubuntu:23.10

# Install wget, gzip, and required build tools
RUN apt-get update && apt-get install -y wget gzip build-essential

# Set a working directory inside the container
WORKDIR /app

# Download and unpack STAR
RUN wget https://github.com/alexdobin/STAR/archive/2.7.10b.tar.gz && \
    tar -xzf 2.7.10b.tar.gz && \
    rm 2.7.10b.tar.gz && \
    cd STAR-2.7.10b/source && \
    make STAR

# Add the STAR binary to the system's PATH
ENV PATH="/app/STAR-2.7.10b/source:${PATH}"

# Copy the script to download the reference genome and genome annotation
COPY download_resources.sh /app/download_resources.sh

# Set the script as executable
RUN chmod +x /app/download_data.sh

# Create a mount point for the "resources" folder
VOLUME /app/resources

# Set the entrypoint to run the download_data.sh script
ENTRYPOINT ["/app/download_data.sh"]
