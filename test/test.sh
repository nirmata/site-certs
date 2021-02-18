#!/bin/bash

url="nginx.cert-test.svc.cluster.local"
external_url="www.google.com"

echo Cleanup Files
mkdir -p conf
rm conf/*
cp nginx/vhost.conf conf/

echo
echo Remove Kyverno
kubectl delete -f https://raw.githubusercontent.com/nirmata/kyverno/master/definitions/install.yaml

echo
echo Cleanup cert-test and site-certs namespaces
kubectl delete ns cert-test
kubectl delete ns site-certs

echo Reinstall Kyverno
kubectl apply -f https://raw.githubusercontent.com/nirmata/kyverno/master/definitions/install.yaml

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
echo Install Kyverno Policy
kubectl apply -f ../example_yamls/kyverno-policy-cm.yaml
kubectl apply -f ../example_yamls/kyverno-policy-mut.yaml


echo 
echo Wait for Kyverno to start up
kubectl wait --for=condition=available --timeout=90s --all deployments -n kyverno |exit 1

echo 
echo Setup site-certs and cert-test namespaces
kubectl create ns cert-test
kubectl create ns site-certs
kubectl create -n site-certs -f ../site-certs.yaml
kubectl label ns cert-test site-certs=do

echo
echo Setup nginx for testing
kubectl -n cert-test apply -f nginx-conf.yaml
kubectl -n cert-test apply -f nginx/nginx.yaml

echo 
echo Setup test statefulsets
kubectl apply -n cert-test -f ../example_yamls/centos-bare-sts.yaml
kubectl apply -n cert-test -f net-test.yaml


echo
echo Waiting for pods to be availble
kubectl wait --for=condition=ready --timeout=60s -n cert-test pod/centos-0 || exit 1
kubectl wait --for=condition=ready --timeout=3s -n cert-test pod/nirmata-net-test-0 || exit 1
kubectl wait --for=condition=available --timeout=3s -n cert-test deployment.apps/nginx || exit 1
IP=`kubectl -n cert-test get services  |grep nginx |awk '{print $3}'`

echo
echo Test server with local certs with unmodified alpine container.  This should fail.
if kubectl -n cert-test exec -it nirmata-net-test-0 -- curl https://$url --output /dev/null  -s  -w "%{http_code}";then
    echo -e \\nCheck failed by passing.  This should never happen.
else
    echo -e \\nCheck passed by failing to recognise Nginx certs
fi

echo
echo Test installed cert with external address
if kubectl -n cert-test exec -it centos-0 -- curl https://$external_url --output /dev/null -s  -w "%{http_code}";then
	echo -e \\nPassed Check
else
	echo Failed Check
fi

echo
echo Test installed cert properly with valid address via centos container. This should pass.
if kubectl -n cert-test exec -it centos-0 -- curl https://$url --output /dev/null  -s  -w "%{http_code}";then
	echo -e \\nPassed Check
else
	echo -e \\nFailed Check
fi

