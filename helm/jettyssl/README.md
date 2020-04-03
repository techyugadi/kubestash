#### Helm Chart for Jetty Application Server with support for HTTPS
This helm chart uses the [techyugadi/jetty](https://hub.docker.com/r/techyugadi/jetty-ssl) docker image.

Modify the `deploy.hostPath` value in values.yaml to point to the path on your host file system where your wab application archives (.war) are located.

Create a SSL key using a tool such as `keytool`, and copy the keystore file to {{ .Values.sslstore.hostPath }}

Populate the file named 'keystorepass' under keys directory in the root folder of this helm chart, with the SSL keystore password.

Populate the file named 'keymgrpass' under keys directory in the root folder of this helm chart, with the SSL keymanager password.

Then run: `helm install [NAME] .`

The above command works on helm v3.

Then follow the service URL and access your web applications deployed on Jetty. Both HTTP and HTTPS URLs can be tested.
