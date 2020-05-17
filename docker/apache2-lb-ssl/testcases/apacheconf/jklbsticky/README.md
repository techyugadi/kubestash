#### Apache2 Mod JK Load-balancer with Session Stickiness
This is a simple load-balancer configuration using `mod_jk` and Tomcat application server. Session stickiness is enabled in the Apache2 configuration (`workers.properties` file).

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
`docker run -it -p 8080:8080 -v /tmp/webapps:/usr/local/tomcat/webapps -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jklbsticky/tomcatconf/tomcat1/server.xml:/usr/local/tomcat/conf/server.xml --name myappsrv1 --network mynetwork tomcat`
Note that the `server.xml` file contains a `jvmRoute` attribute for Engine matching with the worker name in `worker.properties`. This is required for session stickiness.

4. Similarly, create another instance of Tomcat: \
`docker run -it -p 8081:8080 -v /tmp/webapps:/usr/local/tomcat/webapps -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jklbsticky/tomcatconf/tomcat2/server.xml:/usr/local/tomcat/conf/server.xml --name myappsrv2 --network mynetwork tomcat`

5. Start apache web server (docker) on the same network using a virtual host configuration using the `mod_jk` connector. \
`docker run -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jklbsticky/sites-available:/etc/apache2/sites-available -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jklbsticky/workers/workers.properties:/etc/apache2/workers.properties -p 80:80 --name mywebsrv --network mynetwork apache2lbssl`

(That is, volume-mount the above virtual host configuration: note that `workers.properties` file, which is also volume-mounted, refers to the two Tomcat containers named `myappsrv1` and `myappsrv2`. The Tomcat containers also refer to `myappsrv1` and `myappsrv2` respectively in the AJP settings.)

**Testing**: Simply access the URL `http://localhost/mywebapp/` from TWO differernt browsers (say Firefox and Chrome), SEVERAL TIMES. Preferably clear cookies in each browser before starting this test. \
Note the last slash (/) in the URL. \
In each browser, the response will come from a different backend Tomcat instance (IP address), but the request from each browser will land on the SAME instance every time. This can be verified from the fact that the count of the number of visits will be incremented in each browser: \
```
Hello ! Response from: 75b9f78554a2/172.21.0.3. You landed here 1 times
Hello ! Response from: 33aac7b845fa/172.21.0.2. You landed here 1 times
```
You may follow the link from the home page to the next page and back. \
A REST-style URL is also supported: `http://localhost/<some-name>` : it will emit a greeting.\
(This application tests that the `mod_jk` load-balancer behaves correctly even with various URL links from the application home page.)

Failover: By default, `mod_jk` automatically fails over requests. This can be verified by stopping one of the Tomcat containers, and continuing to send requests from the browsers. But sessions are not persisted.

At the end of the tests, you could stop and remove the containers and also the docker network created for this test.
