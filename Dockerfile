FROM ubuntu:bionic
ARG DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    pkg-config \
    wget \
    git \
    gcc \
    g++ \
    libglib2.0-dev \
    cryptsetup \
    runc \
    tzdata

RUN export VERSION=1.18.1 OS=linux ARCH=amd64 && \
    wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && \
    tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz && \
    rm go$VERSION.$OS-$ARCH.tar.gz

ENV GOPATH=/root/go
ENV PATH=/usr/local/go/bin:${PATH}:/root/go/bin   
RUN echo 'export GOPATH=/root/go' >> ~/.bashrc && \
    echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> /root/.bashrc

RUN export VERSION=3.10.3 && \
    mkdir -p $GOPATH/src/github.com/sylabs && \
    cd $GOPATH/src/github.com/sylabs && \
    wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-ce-${VERSION}.tar.gz && \
    tar -xzf singularity-ce-${VERSION}.tar.gz && \
    cd ./singularity-ce-${VERSION} && \
    ./mconfig && \
    make -C ./builddir && \
    make -C ./builddir install

RUN wget https://github.com/ncbi/pgap/raw/prod/scripts/pgap.py -O /bin/pgap.py
RUN chmod +x bin/pgap.py
RUN pgap.py --update && rm -rf /root/.pgap/ 
RUN cat /usr/local/etc/singularity/singularity.conf | awk '{sub(/mount home = yes/,"mount home = no")}1' > tmp.sif && mv tmp.sif /usr/local/etc/singularity/singularity.conf
