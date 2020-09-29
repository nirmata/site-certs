#!/bin/bash

if [ ! -z "$1" ]; then 
    cert_version="1"
fi

mkdir -p ca-certs

docker build -t site-certs-build .

# Run docker to build certs.  We are using Ubuntu as it's easier to do.
docker run --rm -it --mount type=bind,source="$(pwd)",target=/certs site-certs-build /certs/docker-scripts/build-ca-cert.sh $cert_version

# build a configmap
kubectl create configmap site-certs --dry-run --from-file=ca-certs/ -o yaml > site-certs.yaml
echo created site-certs.yaml configmap

# cleanup
#rm -f ca-certs/*
