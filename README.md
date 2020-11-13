# site-certs

This example demonstrates how you can use Kyverno to share a common ca-cert bundle with your own certs for Linux pods on Kubernetes.  The script build-configmap.sh will generate a configmap containing a ca-cert bundle for openssl and a cacerts file for java.  This configmap needs to be mounted to overwrite your existing ca-cert bundle, and cacerts truststore using Kyverno.

To use this repo:
- Place your .crt files to add to the ca-cert bundle in certs.
- Optionally add a cacerts file from (java home)/lib/security in certs,
- Run "./build-configmap.sh" This will produce site-certs.yaml.
- Install Kyverno on your cluster.  
```kubectl apply -f https://raw.githubusercontent.com/nirmata/kyverno/master/definitions/install.yaml```
- Install the config map site-certs.yaml in your default namespace  
```kubectl -n site-certs create -f site-certs.yaml```
- Install a Kyverno policy such as example_yamls/kyverno-policy.yaml  
```kubectl apply -f example_yamls/kyverno-policy-cm.yaml```
```kubectl apply -f example_yamls/kyverno-policy-mut.yaml```
- Tag your namespace with site-certs=do
```kubectl label ns my_namespace site-certs=do```
- Create a deployment with the targeted tag such as example_yamls/centos-bare.yaml.  
```kubectl apply -f example_yamls/centos-bare.yaml -n my_name_space```
- You should see the configmap be mounted on the deployments pods providing the updated certs.  
```kubectl get pod centos-<something> -o yaml -n my_name_space``` (look for volumeMounts)
- Test certs  
```kubectl exec -it centos-<something> -- curl -v some.site.com -n my_name_space```

Files:
- build-configmap.sh                      Main script to create configmap.
- docker-scripts/build-ca-cert.sh         Script executed in docker container to build the cert bundle and trust store.
- example_yamls/centos-bare.yaml          Simple centos container useful to test curl.
- example_yamlsc/entos-hard-coded.yaml    Version of above with the configmaps hard coded in.
- example_yamls/kyverno-policy.yaml       Sample Kyverno policy to add configmap volumes to deployments.
- site-certs.yaml                         A configmap with your new certs files.
- ca-cert/                                This directory contains your generated cert files.
- k8/                                     This directory contains a cronjob to automatically update your cert from certs in new-cert.  This is useful
                                          if you are using Nirmata as you can just edit the new-cert config map to add/remove certs.


Troubleshooting:
- I can not install the configmap "Too long: must have at most 262144 bytes"  
The configmap is too big for apply use either replace or create.
- Kyverno isn't creating the configmap volumes on my pod. 
Is the deployment tagged right? Is it a deployment?  Are you using a current version of Kyverno?
- I need to do this on stateful sets.  
Just create another policy targeting stateful sets instead of deployments or add sts as a target.
- I need a different base ca-cert bundle.  
Put the required base cacerts in the certs directory. 
- It's not putting the cert files in the right place.  
You will need to update kyverno-policy.yam to add different file locations. (Sadly there is no standard for this.)
- I can't pull from docker hub or run apt in my environment.  
You just need a Ubuntu container with ca-certificates and openjdk-11-jre-headless installed. You can also alter docker-scripts/build-ca-cert.sh to use another distro you have locally, but realize non-Debian distros generate certs very differently.


Limitations:
- Some containers put the certs in non-standard places and you'll have to just keep adding new mount locations for the cert files.
- You need to tag your deployments.  You can set it to all deployments, but that might break containers unexpectedly. Some apps use their own certs internally between pods.
- We need to label the namespace to let kyverno know to update them.  You can remove the label but then it will only do new namespaces.
- Kubernetes will not update files from configmaps if you use submounts like we are doing.  You could however build your app to load the cert files in the /site-certs directory which is not a submount.
