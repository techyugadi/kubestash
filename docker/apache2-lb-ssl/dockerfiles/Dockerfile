#Choose Debian
FROM debian:latest

MAINTAINER TechYugadi "techyugadi@gmail.com"

#Don't ask questions during install
ENV DEBIAN_FRONTEND noninteractive

#Install apache2 and enable proxy mode
RUN apt update
RUN apt-get install -y --no-install-recommends \
                bzip2 \
                ca-certificates \
                dirmngr \
                dpkg-dev \
                gcc \
                gnupg \
                libbrotli-dev \
                libcurl4-openssl-dev \
                libjansson-dev \
                liblua5.2-dev \
                libnghttp2-dev \
                libpcre3-dev \
                libssl-dev \
                libxml2-dev \
                libapache2-mod-jk \
                make \
                wget \
                zlib1g-dev
RUN apt -y install apache2

RUN a2enmod proxy \
&& a2enmod proxy_http \
&& a2enmod proxy_ajp \
&& a2enmod rewrite \
&& a2enmod deflate \
&& a2enmod headers \
&& a2enmod proxy_balancer \
&& a2enmod proxy_connect \
&& a2enmod proxy_html \
&& a2enmod ssl \
&& a2enmod socache_shmcb \
&& a2enmod proxy_wstunnel \
&& a2enmod lbmethod_byrequests \
&& a2enmod lbmethod_bytraffic \
&& a2enmod lbmethod_bybusyness \
&& a2enmod lbmethod_heartbeat \
&& a2enmod jk \
&& a2enmod proxy_express \
&& a2enmod status

RUN rm -f /etc/apache2/sites-available/000-default.conf
RUN rm -f /etc/apache2/sites-available/default-ssl.conf

RUN mkdir -p /etc/apache2/ssl

STOPSIGNAL SIGWINCH

#Ports
EXPOSE 80 443

#Volumes
VOLUME /etc/apache2/sites-available

#Launch Apache2 on FOREGROUND
COPY apache-start.sh /opt/
RUN chmod +x /opt/apache-start.sh
ENTRYPOINT ["/opt/apache-start.sh"]
