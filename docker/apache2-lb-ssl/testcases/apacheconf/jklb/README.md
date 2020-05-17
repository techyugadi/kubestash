#### Apache2 Mod JK Load-balancer Configuration
This is a simple load-balancer configuration using `mod_jk` and Tomcat application server. This test-case does not test for session stickiness.

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

3. Star a Tomcat application server docker on the above network. Volume-mount the .war file, and server.xml with AJP connector configuration: \
`docker run -it -p 8080:8080 -v /tmp/webapps:/usr/local/tomcat/webapps -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jklb/tomcatconf/tomcat1/server.xml:/usr/local/tomcat/conf/server.xml --name myappsrv1 --network mynetwork tomcat`

4. Similarly, create another instance of Tomcat: \
`docker run -it -p 8081:8080 -v /tmp/webapps:/usr/local/tomcat/webapps -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jklb/tomcatconf/tomcat2/server.xml:/usr/local/tomcat/conf/server.xml --name myappsrv2 --network mynetwork tomcat`

5. Start apache web server (docker) on the same network using a virtual host configuration using the `mod_jk` connector. \
`docker run -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jklb/sites-available:/etc/apache2/sites-available -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jklb/workers/workers.properties:/etc/apache2/workers.properties -p 80:80 --name mywebsrv --network mynetwork apache2lbssl`

(That is, volume-mount the above virtual host configuration: note that `workers.properties` file, which is also volume-mounted, refers to the two Tomcat containers named `myappsrv1` and `myappsrv2`. The Tomcat containers also refer to `myappsrv1` and `myappsrv2` respectively in the AJP settings.)

**Testing**: Simply access the URL `http://localhost/mywebapp/` from a browser, SEVERAL TIMES. Note the trailing slash (/) in the URL. \
Each time, the response will come from a different backend Tomcat instance. This can be verified from messages like: \
```
Hello ! Response from: 75b9f78554a2/172.21.0.3. You landed here 1 times
Hello ! Response from: 33aac7b845fa/172.21.0.2. You landed here 1 times
```
You may follow the link from the home page to the next page and back. \
A REST-style URL is also supported: `http://localhost/<some-name>` : it will emit a greeting.\
(This application tests that the reverse proxy behaves correctly even with various URL links from the application home page.)

Failover: By default, `mod_jk` automatically fails over requests. This can be verified by stopping one of the Tomcat containers, and continuing to send requests from the browsers. But sessions are not persisted.

At the end of the tests, you could stop and remove the containers and also the docker network created for this test.
