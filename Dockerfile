# DockerFile for grpc4bmi. Installs the C++ bindings in the /usr/local prefix directory in the container. If you are
# planning to run a container with your BMI-enabled model and communicate with it using grpc4bmi, you can use this as a
# base image for your model
FROM ubuntu:24.04
LABEL author="Gijs van den Oord"
LABEL email="g.vandenoord@esciencecenter.nl"

ENV GRPC_VERSION="1.66.1"

# Prerequisite packages
RUN apt-get update && apt-get install -y \
    automake \
    build-essential \
    cmake \
    curl \
    g++ \
    gfortran \
    git \
    libtool \
    libssl-dev \
    make \
    pkg-config \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Build grpc from source
RUN git clone -b v${GRPC_VERSION} --depth 1 https://github.com/grpc/grpc /opt/grpc
WORKDIR /opt/grpc
RUN git submodule update --init --recursive
WORKDIR /opt/grpc/cmake/_build
RUN cmake ../.. \
    -DgRPC_INSTALL=ON \
    -DgRPC_SSL_PROVIDER=package \
    -DgRPC_BUILD_TESTS=OFF \
    -DBUILD_SHARED_LIBS=ON
RUN make install

# Build bmi-c from source
RUN git clone --depth=1 https://github.com/eWaterCycle/grpc4bmi.git /opt/grpc4bmi
WORKDIR /opt/grpc4bmi
RUN git submodule update --init --recursive
RUN mkdir -p /opt/grpc4bmi/cpp/bmi-c/build
WORKDIR /opt/grpc4bmi/cpp/bmi-c/build
RUN cmake ..
RUN make install

# Build grpc4bmi from source
RUN mkdir -p /opt/grpc4bmi/cpp/build
WORKDIR /opt/grpc4bmi/cpp/build
RUN cmake ..
RUN make install
