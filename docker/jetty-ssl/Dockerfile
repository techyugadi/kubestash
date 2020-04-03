# This Dockerfile is based on the official Jetty docker image:
# https://hub.docker.com/_/jetty (although it does not support HTTPS)
FROM openjdk:13-jdk

ENV JETTY_VERSION 9.4.27.v20200227
ENV JETTY_HOME /usr/local/jetty
ENV JETTY_BASE /var/lib/jetty
ENV TMPDIR /tmp/jetty
ENV PATH $JETTY_HOME/bin:$PATH
ENV JETTY_TGZ_URL https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/$JETTY_VERSION/jetty-home-$JETTY_VERSION.tar.gz

# Environment variables for SSL and client certificate authentication
# Ref: https://www.eclipse.org/jetty/documentation/current/jetty-ssl-distribution.html
# Note: we hardcode jetty.sslHost to 0.0.0.0, jetty.sslPort to 8443 
# jetty.sslContext.keyStorePath to etc/keystore
ENV JETTY_SSLCONTEXT_KEYSTOREPASSWORD=
ENV JETTY_SSLCONTEXT_KEYMANAGERPASSWORD=
# Following 3 env vars are required only for client certificate authentication
ENV JETTY_SSLCONTEXT_TRUSTSTOREPATH=
ENV JETTY_SSLCONTEXT_TRUSTSTOREPASSWORD=
ENV JETTY_SSLCONTEXT_NEEDCLIENTAUTH=
# By default, SSL set-up that comes bundled with Jetty, will be used
# if none of the above SSL-specific env vars are set.

RUN set -xe ; \
	#
	# Fetch jetty release into JETTY_HOME
	mkdir -p "$JETTY_HOME" ; \
	cd $JETTY_HOME ; \
	curl -SL "$JETTY_TGZ_URL" -o jetty.tar.gz ; \
	curl -SL "$JETTY_TGZ_URL.asc" -o jetty.tar.gz.asc ; \
	#
	# Verify GPG signatures
	# gpg --batch --verify jetty.tar.gz.asc jetty.tar.gz ; \
	#
	# Unpack jetty
	tar -xvf jetty.tar.gz --strip-components=1 ; \
	sed -i '/jetty-logging/d' etc/jetty.conf ; \
	#
	# Create and configure the JETTY_HOME directory
	mkdir -p "$JETTY_BASE" ; \
	cd $JETTY_BASE ; \
	java -jar "$JETTY_HOME/start.jar" --create-startd \
		--add-to-start="server,http,deploy,jsp,jstl,ext,resources,websocket" ; \
        # Activate default SSL configuration
        java -jar "$JETTY_HOME/start.jar" --add-to-startd=ssl,https ; \
	mkdir -p "$TMPDIR" ; \
	groupadd -r jetty && useradd -r -g jetty jetty ; \
	chown -R jetty:jetty "$JETTY_HOME" "$JETTY_BASE" "$TMPDIR" ; \
	#
	# Cleanup
	rm -rf /tmp/hsperfdata_root ; \
	rm -fr $JETTY_HOME/jetty.tar.gz* ; \
	rm -fr /jetty-keys $GNUPGHOME ; \
	rm -rf /tmp/hsperfdata_root ; \
	#
	# Basic smoke test
	java -jar "$JETTY_HOME/start.jar" --list-config ;

WORKDIR $JETTY_BASE
COPY docker-entrypoint.sh generate-jetty-start.sh /

USER jetty
EXPOSE 8080
EXPOSE 8443
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java","-jar","/usr/local/jetty/start.jar"]
