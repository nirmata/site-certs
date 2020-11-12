# site-certs cronjob

This example demonstrates how you can setup a cronjob to automatically update your customized cacerts.

Via Nirmata:

- Create a catalog app and upload the yaml from this directory.
- Create a config map named new-certs and site-certs with your certs in the catalog app.  These will be the same for now.
- Create a enviroment with a namespace of site-certs.
- Install the app from the catalog as an admin or a user with write access to the cluster.
- When you get a new cert add it to the config map named new-cert.
- The cronjob will regen the ca cert, note it has changed, and replace the site-certs config map.
- Kyverno will sync the new cm across your namespaces.
- Note that submounts will not update so you will need to restart pods to get the updated certs.


Without Nirmata:
- Create a namespace named site-certs 
- Apply the yaml from this directory.
- Create a config map named new-certs and site-certs with your certs.  These will be the same for now.
- When you get a new cert replace new-certs.
- The cronjob will regen the ca cert, note it has changed, and replace the site-certs config map.
- Kyverno will sync the new cm across your namespaces.
- Note that submounts will not update so you will need to restart pods to get the updated certs.
