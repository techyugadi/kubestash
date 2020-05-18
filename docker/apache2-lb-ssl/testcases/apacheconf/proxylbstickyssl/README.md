#### Apache2 Proxy Load-balancer with Session Stickiness and SSL Enforce
This is a simple load-balancer configuration using `mod-proxy-balancer` along with support for session stickiness. Furthermore, the apache webserver is configured to enforce HTTPS redirect for all HTTP requests. This is often a recommended configuration for securing the proxy or load balancer layer. 

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
cp target/mywebapp.war /tmp/webapps/mywebapp.war
```

2. Create a docker network: `docker network create mynetwork`

3. Star a Java application server (Jetty) docker on the above network. Volume-mount the .war file: \
`docker run -p 8080:8080 -v /tmp/webapps:/var/lib/jetty/webapps --name myappsrv1 --network mynetwork jetty`

4. Similarly, create another instance of Jetty: \
`docker run -p 8081:8080 -v /tmp/webapps:/var/lib/jetty/webapps --name myappsrv2 --network mynetwork jetty`

5. Create SSL key and certificate (self-signed), using OpenSSL: \
```
mkdir -p /tmp/sslkeys
cd /tmp/sslkeys
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout apache.key -out apache.crt
```
(You can create the key and certificate in any other directory.)

6. Start apache web server (docker) on the same network using a virtual host configuration with reverse proxy enabled and SSL redirect. \
`docker run -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/proxylbstickyssl/sites-available:/etc/apache2/sites-available -v /tmp/sslkeys:/etc/apache2/ssl -p 80:80 -p 443:443 --network mynetwork --name mywebsrv apache2lbssl`

(That is, volume-mount the above virtual host configuration: note that it refers to the two Jetty containers named `myappsrv1` and `myappsrv2`.)

**Testing**: Simply access the URL `http://localhost/mywebapp/` from TWO differernt browsers (say Firefox and Chrome), SEVERAL TIMES. Preferably clear cookies in each browser before starting this test. \
Note the last slash (/) in the URL. \
In each browser, the response will come from a different backend Jetty instance (IP address), but the request from each browser will land on the SAME instance every time. This can be verified from the fact that the count of the number of visits will be incremented in each browser: \
```
Hello ! Response from: 75b9f78554a2/172.21.0.3. You landed here 1 times
Hello ! Response from: 33aac7b845fa/172.21.0.2. You landed here 1 times
```
In both browsers, the HTTP request to Apache web server will be redirected to HTTPS. 

You may follow the link from the home page to the next page and back. \
A REST-style URL is also supported: `http://localhost/<some-name>` : it will emit a greeting.\
(This application tests that the reverse proxy behaves correctly even with various URL links from the application home page.)

Failover: By default, `mod_proxy_balancer` automatically fails over requests. This can be verified by stopping one of the Jetty containers, and continuing to send requests from both browsers. But sessions are not persisted, and so, on one of the browsers, the visit count will be reset to 1.

At the end of the tests, you could stop and remove the containers and also the docker network created for this test.
