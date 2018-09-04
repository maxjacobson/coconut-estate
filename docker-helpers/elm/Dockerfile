FROM ubuntu:16.04

WORKDIR /elm-code

RUN apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --yes \
    ruby \
    wget && \
    wget "https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz" && \
  tar xzf binaries-for-linux.tar.gz && \
  mv elm /usr/local/bin/ && \
  gem install --no-ri --no-rdoc sinatra pry
