#!/bin/bash 

# We need to install ca-certificates, and jdk
echo install ca-certificates and jdk
apt-get update
apt-get -y install ca-certificates openjdk-11-jre-headless

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
echo "$1" > /certs/ca-certs/version
