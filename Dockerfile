FROM ubuntu

RUN apt-get update
RUN apt-get -y install ca-certificates openjdk-11-jre-headless
