#### Apache2 Default Configuration
The apache2 docker image created in this repo, comes with zero sites available (the files `000-default.conf` and `default-ssl.conf` are removed from the image, so that they don't conflict with load-balancer configurations it is primarily meant for).

(Assume this github repo has been cloned to the `~/github` directory on your machine.)

Create a docker image using the given Dockerfile (if not already created): let the name of the image be `apache2lbssl`. \
```
cd ~/github/kubestash/docker/apache2-lb-ssl/dockerfiles
docker build -t apache2lbssl .
```

But, just to test out the default Apache2 web server configuration, the above two configuration files are also placed in this repo. To start up apache2 in default mode (without any load-balancer / reverse-proxy), simply run: \
`docker run -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/defaultconf/sites-available:/etc/apache2/sites-available -p 80:80 --name mywebsrv apache2lbssl`

(That is, volume-mount the above two default virtual host configurations.)

**Testing**: Simply access the URL `http://localhost` from a browser.
