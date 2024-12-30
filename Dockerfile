# Build and install Cardinal in a Docker image without conda
#
# Divided into the following targets:
#
# cardinal-base: starting from an Ubuntu 24.04 image:
#     * installs all required packages
#
# cardinal-clone:
#     * clone cardinal repo
#
# cardinal-deps:
#     * run the get-dependency script
#
# cardinal-build:
#     * make cardinal using specific environment variables
#
FROM ubuntu:24.04 AS cardinal-base

# Install necessary dependencies
RUN apt-get update --yes && \
    apt-get install --yes \
        git \
        make \
        autoconf \
        automake \
        libtool \
        flex \
        bison \
        cmake \
        g++ \
        gfortran \
        libhdf5-dev \
        mpich \
        libtirpc-dev \
        python3 \
        python3-pip \
        python3-packaging \
        python3-jinja2 \
        python3-yaml \
        python3-pkgconfig\
        curl 
FROM cardinal-base AS cardinal-clone

# COPY . /cardinal    
WORKDIR /cardinal-build



RUN curl https://anl.box.com/shared/static/uhbxlrx7hvxqw27psymfbhi7bx7s6u6a.xz  

RUN git clone --branch custom_scripts git@github.com:magnoxemo/cardinal.git
FROM cardinal-clone AS cardinal-deps

WORKDIR /cardinal-build/cardinal

ENV LIBMESH_JOBS=16

RUN ./scripts/get-dependencies.sh && \
    ./contrib/moose/scripts/update_and_rebuild_petsc.sh && \
    ./contrib/moose/scripts/update_and_rebuild_libmesh.sh && \
    ./contrib/moose/scripts/update_and_rebuild_wasp.sh 

FROM cardinal-deps AS cardinal-build

WORKDIR /cardinal-build/cardinal

RUN export NEKRS_HOME=/cardinal-build/cardinal/install && \
    make -j8



#docker build -t cardinal-build .
#docker run -it -v  cardinal-build

