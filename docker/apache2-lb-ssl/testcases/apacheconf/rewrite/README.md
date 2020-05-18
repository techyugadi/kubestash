#### Apache2 Proxy Load-balancer with Rewrite Configuration
This test case uses a simple load-balancer configuration using `mod-proxy-balancer` with a Rewrite rule. This test-case does not test for session stickiness.

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
`docker run -p 8080:8080 -v /tmp/webapps:/var/lib/jetty/webapps --name myappsrv1 --network mynetwork jetty`

4. Similarly, create another instance of Jetty: \
`docker run -p 8081:8080 -v /tmp/webapps:/var/lib/jetty/webapps --name myappsrv2 --network mynetwork jetty`

5. Start apache web server (docker) on the same network using a virtual host configuration with reverse proxy enabled. \
`docker run -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/rewrite/sites-available:/etc/apache2/sites-available -p 80:80 --network mynetwork --name mywebsrv apache2lbssl`

(That is, volume-mount the above virtual host configuration: note that it refers to the two Jetty containers named `myappsrv1` and `myappsrv2`.)

**Testing**: Simply access the URL `http://localhost/mywebapp` from a browser, SEVERAL TIMES. Note that trailing slash (/) is NOT needed. \
Each time, the response will come from a different backend Jetty instance. This can be verified from messages like: \
```
Hello ! Response from: 75b9f78554a2/172.21.0.3. You landed here 1 times
Hello ! Response from: 33aac7b845fa/172.21.0.2. You landed here 1 times
```
You may follow the link from the home page to the next page and back. \
A REST-style URL is also supported: `http://localhost/<some-name>` : it will emit a greeting.\
(This application tests that the reverse proxy behaves correctly even with various URL links from the application home page.)

At the end of the tests, you could stop and remove the containers and also the docker network created for this test.

**Rewrite Rule**: The apache configuration file contains a rewrite rule: \
``` 
RewriteEngine on
RewriteRule ^/mywebapp$ /mywebapp/ [R]
```
Without the rewrite rule, a trailing slash would have been needed when accessing the appliation, like: `http://localhost/mywebapp`. Otherwise, when accessing the next page from the home page, an error would have occurred. \
But users cannot be expected to type in the trailing slash always. The rewrite rule takes care of it. This also tests the Rewrite engine (`mod_rewrite`).
