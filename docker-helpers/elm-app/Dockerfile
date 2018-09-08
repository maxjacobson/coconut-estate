FROM node:8.11.4-jessie

WORKDIR /elm-code

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

RUN apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --yes \
    wget && \
    wget "https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz" && \
    tar xzf binaries-for-linux.tar.gz && \
    mv elm /usr/local/bin/

USER node

RUN mkdir ~/.npm-global && npm install -g create-elm-app@2.0.3
ENV PATH="/home/node/.npm-global/bin:${PATH}"
USER root
