#!/bin/bash


mkdir -p ca-certs

docker build -t site-certs-build .

# Run docker to build certs.  We are using Ubuntu as it's easier to do.
docker run --rm -it --mount type=bind,source="$(pwd)",target=/certs site-certs-build /build-ca-cert.sh $1


# cleanup
#rm -f ca-certs/*
