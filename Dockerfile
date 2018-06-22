FROM ubuntu:16.04

RUN apt-get update && \
  apt-get upgrade --yes && \
  apt-get install --yes \
  build-essential \
  curl \
  libssl-dev \
  openssl \
  pkg-config

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain 1.27.0
ENV PATH="/root/.cargo/bin:${PATH}"
