#!/bin/bash -x

# We need to install ca-certificates which is not in the base docker image for Ubuntu
echo install ca-certificates
apt-get update 
apt-get -y install ca-certificates openjdk-11-jre-headless
echo ; echo

# Create local cert files and tel ca-certificates to use them
mkdir -p /usr/local/share/ca-certificates
rm -f /usr/local/share/ca-certificates/*

echo build java cacerts keystore
cp /certs/certs/*.crt /usr/local/share/ca-certificates

if [ -e /certs/certs/cacerts ];then 
    cp /certs/certs/cacerts /certs/ca-certs/cacerts
else
    cp /certs/certs/cacerts /etc/ssl/certs/java/cacerts
fi
keytool  -import  -trustcacerts  -file /certs/certs/IssuerDigicert.crt -keystore /certs/ca-certs/cacerts -storepass changeit


# generate your cert bundle
echo build cert bundle
ls /usr/local/share/ca-certificates/* >> /etc/ca-certificates.conf
update-ca-certificates 

# Store cert bundle in Red Hat and Debian styles
cp /etc/ssl/certs/ca-certificates.crt /certs/ca-certs/

