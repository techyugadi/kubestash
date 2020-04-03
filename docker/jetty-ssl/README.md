This image of java-based Jetty Application Server is an enhancement of the official Jetty docker image (`jetty`) , to support **HTTPS**.

Jetty comes bundled with HTTPS support, with a pre-installed keystore (`$JETTY_BASE/etc/keystore`). To use the default SSL set-up simply run:

`docker run -p 8080:8080 -p 8443:8443 -v ~/jetty/webapps:/var/lib/jetty/webapps techyugadi/jetty-ssl`

The HTTP port is 8080 and HTTPS port is 8443. This assumes you want to mount Jetty web application archives using docker volumes.

To mount your own SSL certificate, run the following command:

`docker run -p 8080:8080 -p 8443:8443 -v ~/jetty/webapps:/var/lib/jetty/webapps -v ~/jetty/keystore:/var/lib/jetty/etc/keystore -e JETTY_SSLCONTEXT_KEYSTOREPASSWORD=<keystore_password> -e JETTY_SSLCONTEXT_KEYMANAGERPASSWORD=<keymanager_password> techyugadi/jetty-ssl`

![keytool](https://github.com/techyugadi/kubestash/blob/master/img/keystore.png)

For example, in the above command using keytool, the first password entered corresponds to `JETTY_SSLCONTEXT_KEYSTOREPASSWORD` and the last password entered corresponds to `JETTY_SSLCONTEXT_KEYMANAGERPASSWORD`. 

Note: On some platforms, an option is given to set the same password for keystore and keymanager.

Furthermore, to enable client authentication, the following environment variables are supported (set `JETTY_SSLCONTEXT_NEEDCLIENTAUTH=true`) 

`JETTY_SSLCONTEXT_TRUSTSTOREPATH`, `JETTY_SSLCONTEXT_TRUSTSTOREPASSWORD`, `JETTY_SSLCONTEXT_NEEDCLIENTAUTH`.

The HTTPS port and keystore location (`$JETTY_BASE/etc/keystore`) are kept unaltered.
