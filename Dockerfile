FROM tercen/dartrusttidy:travis-17

# Get Salmon binaries and add them to the PATH
RUN wget https://github.com/COMBINE-lab/salmon/releases/download/v1.4.0/salmon-1.4.0_linux_x86_64.tar.gz
RUN tar xzvf salmon-1.4.0_linux_x86_64.tar.gz
ENV PATH="/salmon-latest_linux_x86_64/bin:${PATH}"


# Get H. Sapiens cDNA FASTA and index it
RUN wget http://ftp.ensembl.org/pub/release-103/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
RUN salmon index -t Homo_sapiens.GRCh38.cdna.all.fa.gz -i hsapiens_index

USER root
WORKDIR /operator

RUN git clone https://github.com/tercen/fastq_to_counts_operator.git

WORKDIR /operator/fastq_to_counts_operator

RUN echo 1.1.11.3 && git pull
RUN echo 1.1.11.3 && git checkout

RUN R -e "install.packages('renv')"
RUN R -e "renv::restore(confirm=FALSE)"

ENTRYPOINT [ "R","--no-save","--no-restore","--no-environ","--slave","-f","main.R", "--args"]
CMD [ "--taskId", "someid", "--serviceUri", "https://tercen.com", "--token", "sometoken"]
