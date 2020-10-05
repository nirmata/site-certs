#!/bin/bash

if [ -z "$1" ]; then
    version=$(date '+%d.%m.%Y.%H.%M.%S')
else
    version=$1
fi

echo; echo build java cacerts keystore

if [ -e /certs/certs/cacerts ];then
    cp /certs/certs/cacerts /certs/ca-certs/cacerts
else
    cp /etc/ssl/certs/java/cacerts /certs/certs/cacerts
fi

for cert in /certs/certs/*.crt;do
    # Note I'm assuming the password is the standard one
    yes |keytool  -import  -trustcacerts  --alias "site$(basename -- $cert)" -file "$cert" -keystore /certs/ca-certs/cacerts -storepass changeit
done

# Position cert files
mkdir -p /usr/local/share/ca-certificates
rm -f /usr/local/share/ca-certificates/*
cp /certs/certs/*.crt /usr/local/share/ca-certificates

# generate your cert bundle
echo; echo build cert bundle
ls /usr/local/share/ca-certificates/* >> /etc/ca-certificates.conf
update-ca-certificates

# Store cert bundle
cp /etc/ssl/certs/ca-certificates.crt /certs/ca-certs/
echo "$version" > /certs/ca-certs/version

cd /certs ||exit
# build a configmap
kubectl create configmap site-certs --dry-run --from-file=ca-certs/ -o yaml |kubectl label -f- --dry-run -o yaml --local version=$version > site-certs.yaml
echo created site-certs.yaml configmap
