#!/bin/bash

mkdir -p /certs/certs/ /certs/ca-certs/
cp /new-certs/* /certs/certs/
/build-ca-cert.sh

if diff /certs/ca-certs/ca-certificates.crt /site-certs/ca-certificates.crt; then
  echo No change of certs
else 
  echo certs change detected
  kubectl -n site-certs replace -f /certs/site-certs.yaml
fi


