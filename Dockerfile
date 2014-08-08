# DOCKER-VERSION 1.0.1
FROM phusion/passenger-full:0.9.11
MAINTAINER Jethro Yu "comet.jc@gmail.com"

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...
#############################################################

# Switch ruby version
RUN ruby-switch --set ruby2.0

# If host is running squid-deb-proxy on port 8000, populate /etc/apt/apt.conf.d/30proxy
# By default, squid-deb-proxy 403s unknown sources, so apt shouldn't proxy ppa.launchpad.net
RUN route -n | awk '/^0.0.0.0/ {print $2}' > /tmp/host_ip.txt
RUN echo "HEAD /" | nc `cat /tmp/host_ip.txt` 8000 | grep squid-deb-proxy \
  && (echo "Acquire::http::Proxy \"http://$(cat /tmp/host_ip.txt):8000\";" > /etc/apt/apt.conf.d/30proxy) \
  && (echo "Acquire::http::Proxy::ppa.launchpad.net DIRECT;" >> /etc/apt/apt.conf.d/30proxy) \
  || echo "No squid-deb-proxy detected on docker host"

# Update base image
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository -s -y ppa:nginx/stable
RUN apt-get update

RUN apt-get upgrade -y

# Install nginx build tools
# Download nginx source
RUN apt-get build-dep -y nginx
RUN cd /build && apt-get source nginx
RUN mv /build/nginx-*/ /build/nginx/

# Download ngx_pagespeed source
RUN apt-get install -y wget unzip
# check https://developers.google.com/speed/pagespeed/module/build_ngx_pagespeed_from_source for new version
ENV NPS_VERSION 1.8.31.4
RUN wget http://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip
RUN unzip release-${NPS_VERSION}-beta.zip
RUN wget http://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz --progress=dot:giga
RUN tar -xzvf ${NPS_VERSION}.tar.gz -C ngx_pagespeed-release-${NPS_VERSION}-beta/
RUN mv ngx_pagespeed-release-${NPS_VERSION}-beta /build/nginx/debian/modules/

# remove original nginx
RUN apt-get remove -y nginx-*

# include pagespeed & passenger module in configure
RUN \
  config=`passenger-config --root` && \
  setting=`grep nginx_module_source_dir $config` && \
  eval $setting && \
  echo $nginx_module_source_dir && \
  NGX_PAGESPEED_DIR='$(MODULESDIR)/ngx_pagespeed-release-${NPS_VERSION}-beta' && \
  sed -i -e "s#^common_configure_flags.*#&\n--add-module=$NGX_PAGESPEED_DIR --add-module=$nginx_module_source_dir' \\'#" /build/nginx/debian/rules

# Increase the source package version, since this will help you pin the package later.
RUN sed -i -e "1 s/)/-speed-passenger)/" /build/nginx/debian/changelog

# Build nginx
RUN cd /build/nginx && dpkg-buildpackage -b
RUN dpkg --force-confmiss --force-confold -i /build/nginx-extras*.deb /build/nginx-common*.deb /build/nginx_*.deb


RUN rm -rf /build/{nginx*.deb,nginx_*,nginx}
#############################################################
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
