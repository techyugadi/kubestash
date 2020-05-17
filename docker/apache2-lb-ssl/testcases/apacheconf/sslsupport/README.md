#### Apache2 SSL Support
This configuration allows our web-sites to be accessible through both HTTP and HTTPS.

Create a docker image using the given Dockerfile (if not already created): let the name of the image be `apache2lbssl`. \
```
cd ~/github/kubestash/docker/apache2-lb-ssl/dockerfiles
docker build -t apache2lbssl .
```

A small set of HTML and CSS files are available in this repo (`kubestash/docker/apache2-lb-ssl/testcases/apps/webpages`) to test this configuration.

1. Create SSL key and certificate (self-signed), using OpenSSL: \
```
mkdir -p /tmp/sslkeys
cd /tmp/sslkeys
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout apache.key -out apache.crt
```
(You can create the key and certificate in any other directory.)
 
2. Start apache web server (docker) using a virtual host configuration with SSL support. \
`docker run -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apacheconf/sslsupport/sites-available:/etc/apache2/sites-available -v ~/github/kubestash/docker/apache2-lb-ssl/testcases/apps/webpages:/var/www/html -v /tmp/sslkeys:/etc/apache2/ssl -p 80:80 -p 443:443 --name mywebsrv apache2lbssl` \
(That is, volume-mount the above virtual host configuration and the static web pages. Also volume-mount the SSL keys. The directory `/etc/apache2/ssl` has been created in this docker image.)

**Testing**: Simply access the URL `http://localhost` and `https://localhost`, from a browser. Both URLs should work.\
Follow the link from the home page to the next page and back. Some text should be in red color, indicating that the CSS file has been correctly loaded. \
Note: Since a self-signed certificat is being used, the browser will show a warning message. Add an exception for this certificate.
