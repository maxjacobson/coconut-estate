FROM ubuntu:16.04

WORKDIR /rust-monorepo

RUN apt-get update && \
  apt-get upgrade --yes && \
  apt-get install --yes \
  build-essential \
  curl \
  libpq-dev \
  libssl-dev \
  openssl \
  pkg-config

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain 1.28.0
ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install --quiet diesel_cli --no-default-features --features postgres && \
    diesel --version | grep --quiet "diesel 1.3"
