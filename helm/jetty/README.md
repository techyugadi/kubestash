#### Helm Chart for Jetty Application Server
This helm chart uses the official [jetty](https://hub.docker.com/_/jetty) docker image.

Modify the `deploy.hostPath` value in values.yaml to point to the path on your host file system, where your web application archives (.war) are located.

Then run: `helm install [NAME] .`

The above command works on helm v3.

Then follow the service URL and access your web applications deployed on Jetty.
