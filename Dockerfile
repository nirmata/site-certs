# Use current LTS
FROM ubuntu:latest

RUN apt-get update &&\
    apt-get -y install ca-certificates openjdk-11-jre-headless curl --no-install-recommends &&\
    curl https://storage.googleapis.com/kubernetes-release/release/v1.17.12/bin/linux/amd64/kubectl -o /bin/kubectl &&\
    chmod 755 /bin/kubectl &&\
    apt-get -y remove curl  &&\
    apt-get autoremove -y &&\
    apt-get clean all

COPY docker-scripts/build-ca-cert.sh /

COPY k8/update.sh /

# Can we do this as non-root with enough perm changes?

RUN chmod 755 /update.sh /build-ca-cert.sh
