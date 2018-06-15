FROM ubuntu:16.04

RUN apt-get update && \
  apt-get upgrade --yes && \
  apt-get install --yes \
  build-essential \
  curl \
  libssl-dev \
  openssl \
  pkg-config

RUN curl https://sh.rustup.rs -sSf --output rustup.sh && sh rustup.sh -y && rm rustup.sh
ENV PATH="/root/.cargo/bin:${PATH}"
