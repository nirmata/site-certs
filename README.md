# site-certs

This example is how you can use Kyverno to share a common ca-cert bundle with local site certs for Linux pods on Kubernetes.  The script build-configmap.sh will generate a configmap containing a basic ca-cert set.  This configmap can be mounted on /etc/ssl to overwrite your existing ca-cert bundle using Kyverno.

To use this repo:
- Place your .crt to add to the ca-cert bundle.
- Run build-configmap.sh
- Install Kyverno on your cluster.
- Install the config map site-certs.yaml in your default namespace
- Install a Kyverno policy such as example_yamls/kyverno.yaml
- Create a deployment with the targeted tag such as example_yamls/centos-bare.yaml.
- You should see the configmap be mounted on the deployments pods providing the updated ca-cert bundle.

