#### Apache2 SSL Passthrough Configuration
In this configuration, Apache2 listens on an HTTP port and tunnels HTTPS requests to a backend server (e.g., an appserver like Jetty).

Create a docker image using the given Dockerfile (if not already created): let the name of the image be `apache2lbssl`. \
```
cd ~/github/kubestash/docker/apache2-lb-ssl/dockerfiles
docker build -t apache2lbssl .
```

1. Compile and package the Java web application provided under `kubestash/docker/apache2-lb-ssl/testcases/apps/jettyapp`: \
```
cd kubestash/docker/apache2-lb-ssl/testcases/apps/jettyapp
mvn mvn clean install -DskipTests=true
```
Copy the .war file to a suitable location: \
```
mkdir -p /tmp/webapps
cp target/mywebapp.war /tmp/webapps/ROOT.war
```
2. Create a keystore for Jetty using keytool: \
```
mkdir -p /tmp/jettyssl
cd /tmp/jettyssl
keytool -keystore keystore -alias jetty -genkey -keyalg RSA -validity 360
```
Let the keystore password be `keypass`, and let's just use the same password for key manager.\

3. Create a docker network: `docker network create mynetwork`

4. Start a Java application server (Jetty) docker on the above network. Volume-mount the .war file. Note that HTTPS port 8443 is also exposed: \
For this testcase we will use the docker image `techyugadi/jetty-ssl` which supports HTTPS access to Jetty. \
`docker run -p 8080:8080 -p 8443:8443 -v /tmp/webapps:/var/lib/jetty/webapps -v /tmp/jettyssl/keystore:/var/lib/jetty/etc/keystore -e JETTY_SSLCONTEXT_KEYSTOREPASSWORD=keypass -e JETTY_SSLCONTEXT_KEYMANAGERPASSWORD=keypass --name myappsrv --network mynetwork techyugadi/jetty-ssl`

5. Start apache web server (docker) on the same network using a virtual host configuration with reverse proxy enabled. \
`docker run -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/sslpassthru/sites-available:/etc/apache2/sites-available -p 80:80 --name mywebsrv --network mynetwork apache2lbssl` 
(That is, volume-mount the above virtual host configuration: note that it refers to the Jetty container named `myappsrv`.)

**Testing**: Simply access the URL `http://localhost` from a browser. \
Follow the link from the home page to the next page and back. \
A REST-style URL is also supported: `http://localhost/<some-name>` : it will emit a greeting.\
(This application tests that the reverse proxy behaves correctly even with various URL links from the application home page.)

Although we accessed the Apache2 web server on an HTTP port, the request was correctly passed through to the HTTPS port on the backend Jetty application server.

At the end of the tests, you could stop and remove the containers and also the docker network created for this test.
