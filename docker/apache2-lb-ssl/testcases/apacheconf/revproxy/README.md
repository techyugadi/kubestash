#### Apache2 Reverse Proxy Configuration
In this configuration Apache web server acts as a reverse proxy, sending requests to a backend server (Jetty application server in our example).

(Assume this github repo has been cloned to the `~/github` directory on your machine.)

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

2. Create a docker network: `docker network create mynetwork`

3. Star a Java application server (Jetty) docker on the above network. Volume-mount the .war file: \
`docker run -p 8080:8080 -v /tmp/webapps:/var/lib/jetty/webapps --name myappsrv --network mynetwork jetty`

4. Start apache web server (docker) on the same network using a virtual host configuration with reverse proxy enabled. \
`docker run -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/revproxy/sites-available:/etc/apache2/sites-available -p 80:80 --name mywebsrv --network mynetwork apache2lbssl` 
(That is, volume-mount the above virtual host configuration: note that it refers to the Jetty container named `myappsrv`.)

**Testing**: Simply access the URL `http://localhost` from a browser. \
Follow the link from the home page to the next page and back. \
A REST-style URL is also supported: `http://localhost/<some-name>` : it will emit a greeting.\
(This application tests that the reverse proxy behaves correctly even with various URL links from the application home page.)

At the end of the tests, you could stop and remove the containers and also the docker network created for this test.
