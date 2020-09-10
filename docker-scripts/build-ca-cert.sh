#!/bin/bash 

# We need to install ca-certificates which is not in the base docker image for Ubuntu
echo install ca-certificates
apt-get update 
apt-get -y install ca-certificates
echo ; echo

# Create local cert files and tel ca-certificates to use them
mkdir -p /usr/local/share/ca-certificates
cp /certs/certs/* /usr/local/share/ca-certificates
ls /usr/local/share/ca-certificates/* >> /etc/ca-certificates.conf

# generate your cert bundle
echo build cert bundle
update-ca-certificates 

# Store cert bundle in Red Hat and Debian styles
cp /etc/ssl/certs/ca-certificates.crt /certs/ca-certs/
cp /etc/ssl/certs/ca-certificates.crt /certs/ca-certs/ca-bundle.crt
cp /etc/ssl/certs/ca-certificates.crt /certs/ca-certs/cert.pem
cp /etc/ssl/openssl.cnf /certs/ca-certs/

