# site-certs cronjob

This example demonstrates how you can setup a cronjob to automatically update your customized cacerts.

Via Nirmata:

- Create a catalog app and upload the yaml from this directory.
- Import configmaps new-certs and site-certs with the certs in ../example_yamls.  These will be the same for now.
- Create a enviroment with a namespace of site-certs.
- Install the app from the catalog as an admin or a user with write access to the cluster.
- When you get a new cert add it to the config map named new-cert.
- The cronjob will regen the ca cert, note it has changed, and replace the site-certs config map.
- Enable Kyverno on the cluster
- Add the two policies from ../example_policies
- Label a test env with site-cert=do
- Kyverno will copy the site-cert and keep it up to date. Note that submounts will not update so you will need to restart pods to get the updated certs.
- Create a sts or deployment with the site-certs=do label see ../example_yamls/*bare* for examples.


Without Nirmata:
- Create a namespace named site-certs 
- Apply the yaml from this directory.
- Create a config map named new-certs and site-certs with your certs.  These will be the same for now.
- When you get a new cert replace new-certs.
- The cronjob will regen the ca cert, note it has changed, and replace the site-certs config map.
- Add the two policies from ../example_policies
- Label a test namespace with site-cert=do
- Kyverno will copy the site-cert and keep it up to date. Note that submounts will not update so you will need to restart pods to get the updated certs.
- Create a sts or deployment with the site-certs=do label see ../example_yamls/*bare* for examples.
