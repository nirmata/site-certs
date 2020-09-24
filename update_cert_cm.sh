#!/bin/bash 

for ns in $(kubectl get ns --output=jsonpath={.items..metadata.name});do
    kubectl -n $ns replace -f site-certs.yaml || kubectl -n $ns create -f site-certs.yaml
done
