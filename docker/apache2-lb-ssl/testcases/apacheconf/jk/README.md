#### Apache2 Mod JK Proxy Configuration
In this configuration Apache web server sends requests to backend Tomcat application server over AJP protocol using `mod_jk`.

(Assume this github repo has been cloned to the `~/github` directory on your machine.)

Create a docker image using the given Dockerfile (if not already created): let the name of the image be `apache2lbssl`. \
```
cd ~/github/kubestash/docker/apache2-lb-ssl/dockerfiles
docker build -t apache2lbssl .
```

1. Compile and package the Java web application provided under `kubestash/docker/apache2-lb-ssl/testcases/apps/tomcatapp`: \
```
cd kubestash/docker/apache2-lb-ssl/testcases/apps/tomcatapp
mvn mvn clean install -DskipTests=true
```
Copy the .war file to a suitable location: \
```
mkdir -p /tmp/webapps
cp target/mywebapp.war /tmp/webapps/mywebapp.war
```

2. Create a docker network: `docker network create mynetwork`

3. Star a Tomcat application server (Jetty) docker on the above network. Volume-mount the .war file, and server.xml modified to support AJP on port 8009 \
`docker run -it -p 8080:8080 -v /tmp/webapps:/usr/local/tomcat/webapps -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jk/tomcatconf/server.xml:/usr/local/tomcat/conf/server.xml --name myappsrv --network mynetwork tomcat`

4. Start apache web server (docker) on the same network using a virtual host configuration with reverse proxy enabled. \
`docker run -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jk/sites-available:/etc/apache2/sites-available -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jk/workers/workers.properties:/etc/apache2/workers.properties -p 80:80 --name mywebsrv --network mynetwork apache2lbssl`
(That is, volume-mount the above virtual host configuration: note that the `workers.properties` file, which is also volume-mounted, refers to the Tomcat container named `myappsrv`. Tomcat `server.xml` also refers to the container named `myappsrv` in the AJP settings.)

**Testing**: Simply access the URL `http://localhost/mywebapp/` from a browser. Note that the trailing slash in the URL, is needed. \
Follow the link from the home page to the next page and back. \
A REST-style URL is also supported: `http://localhost/<some-name>` : it will emit a greeting.\
(This application tests that the `mod_jk` connector  behaves correctly even with various URL links from the application home page.)

At the end of the tests, you could stop and remove the containers and also the docker network created for this test.
