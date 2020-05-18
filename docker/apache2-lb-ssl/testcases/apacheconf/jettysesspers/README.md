#### Jetty Session Persistence Configuration with Apache2 Web Server
This directory contains a `docker-compose` yaml file to set up a Jetty cluster (two instances) with session stickiness and session failover. The sessions are stored in MySQL database.

The same Apache2 Dockerfile is copied into this directory, just for convenience.

(Assume this github repo has been cloned to the `~/github` directory on your machine.)

To set up this configuration: \
```
cd ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/jettysesspers
docker-compose up
```

Before running the test: \
1. Build the web application (`jettyapp`) using maven, and copy the file `target\mywebapp` into the appropriate directory for volume mount: `./volumes/jetty/webapps`. \
2. Create a SSL key and certificate (self-signed) for secure access to Apache Web server: \
```
cd ./volumes/apache2/sslkeys 
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout apache.key -out apache.crt
```

This set-up includes redirection to the HTTPS URL at the Apache web server layer, and a rewrite rule.

**Testing**: Access the web applictation from two different browsers (say Firefox and Chrome). The URL is: `http://localhost/mywebapp`. (Preferably clear cookies in each browser before running this test.)

Now, reload the URL in each browser, several times. The count of the number of times this page has been visited, will be incremented. The Jetty instance from which the request was served, will also be displayed.

Stop one of the Jetty containers (using `docker stop`). Continue to load the page from the browser, which was hitherto served by the stopped container. The request will failover to the other Jetty container, but the visit count will still be incremented (and not reset), indicating session persistence.
