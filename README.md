# site-certs

This example is how you can use Kyverno to share a common ca-cert bundle with local site certs for Linux pods on Kubernetes.  The script build-configmap.sh will generate a configmap containing a basic ca-cert set.  This configmap can be mounted on /etc/ssl to overwrite your existing ca-cert bundle using Kyverno.

To use this repo:
- Place your .crt file to add to the ca-cert bundle.
- Optonally add a cacerts from (java home)/lib/security
- Run build-configmap.sh
- Install Kyverno on your cluster.
- Install the config map site-certs.yaml in your default namespace
- Install a Kyverno policy such as example_yamls/kyverno-policy.yaml
- Create a deployment with the targeted tag such as example_yamls/centos-bare.yaml.
- You should see the configmap be mounted on the deployments pods providing the updated ca-cert bundle.

Files:
- build-configmap.sh                      Main script
- docker-scripts/build-ca-cert.sh         Script executed in docker container to build the cert bundle and trust store
- example_yamls/centos-bare.yaml          Simple centos container useful to test curl.
- example_yamlsc/entos-hard-coded.yaml    Version of above with the configmaps hard coded in.
- example_yamls/kyverno-policy.yaml       Sample Kyverno policy to add configmap volumes to deployments.


Troubleshooting:
- Kyverno isn't creating the configmap volumes on my pod. 
Is the deployment tagged right? Is it a deployment?  Are you using a current version of Kyverno?
- I need a different ca-cer bundle.  
You can change the container used to produce the ca certs, but note different distros put thing in different places and use different scripts.
- It's not putting the cert files in the right place.
You can simple update the mounts to add different file locations.
- I can't pull from docker hub or run apt in my environment.
You just need a Ubuntu container with ca-certificates and openjdk-11-jre-headless installed.  Or modify it to use another distro you have locally.


Limitations:
- Some containers put the certs in non-standard places and you'll have to just keep new mount locations for the cert files.
- You need to tag your deployments.  You can set it to all deployments, but that might break unexpectedly. Some apps use their own certs internally between pods.
- Kyverno only copies the configmap when namespaces are created.  You'll need to update the configmap in all namespaces for now.
