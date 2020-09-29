#!/bin/bash

url="nginx.cert-test.svc.cluster.local"

echo Cleanup Files
mkdir -p conf
rm conf/*
cp nginx/vhost.conf conf/

echo
echo Reinstall Kyverno
kubectl delete -f https://raw.githubusercontent.com/nirmata/kyverno/master/definitions/install.yaml
kubectl apply -f https://raw.githubusercontent.com/nirmata/kyverno/master/definitions/install.yaml

echo
echo Cleanup cert-test and site-certs namespaces
kubectl delete ns cert-test
kubectl delete ns site-certs

echo
echo Install Kyverno Policy
kubectl apply -f ../example_yamls/kyverno-policy.yaml

echo
echo Generate certs for $url 
openssl \
  req -out conf/certificate.csr \
  -new -newkey rsa:2048 -nodes -keyout conf/privatekey.pem \
  -subj "/C=US/ST=OR/L=Portland/O=Docker/CN=$url"
openssl \
  req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
   -keyout conf/privatekey.pem \
   -out conf/certificate.crt \
  -subj "/C=US/ST=OR/L=Portland/O=Docker/CN=$url"

kubectl create configmap nginx-conf --dry-run --from-file=conf -o yaml > nginx-conf.yaml

cp conf/certificate.crt ../certs/

cd ../
./build-configmap.sh
cd -


echo 
echo Setup site-certs and cert-test namespaces
kubectl create ns cert-test
kubectl create ns site-certs
kubectl create -n site-certs -f ../site-certs.yaml

echo
echo Setup nginx for testing
kubectl -n cert-test apply -f nginx-conf.yaml
kubectl -n cert-test apply -f nginx/nginx.yaml
kubectl -n cert-test apply -f net-test.yaml

echo 
echo Setup Centos test sts
kubectl apply -n cert-test -f ../example_yamls/centos-bare-sts.yaml

echo
echo Waiting for pods to be availble
sleep 30
IP=`kubectl -n cert-test get services  |grep nginx |awk '{print $3}'`
#echo 
#echo Test without cert externally.  This should fail.
#curl https://$IP

echo
echo Test with wrong url via centos container.  This should fail.
kubectl -n cert-test exec -it centos-0 -- curl https://$IP

echo
echo Test installed cert properly with valid address via centos container. This should pass.
if kubectl -n cert-test exec -it centos-0 -- curl https://$url --output /dev/null ;then
	echo Passed Check
else
	echo Failed Check
fi

