#!/bin/bash

if [ ! -z "$1" ]; then 
    cert_version="1"
fi

mkdir -p ca-certs

# Run docker to build certs.  We are using Ubuntu as it's easier to do.
docker run --rm -it --mount type=bind,source="$(pwd)",target=/certs ubuntu /certs/docker-scripts/build-ca-cert.sh $cert_version

# build a configmap
kubectl create configmap site-certs --dry-run --from-file=ca-certs/ -o yaml > site-certs.yaml
echo created site-certs.yaml configmap

# cleanup
#rm -f ca-certs/*
