# DOCKER-VERSION 1.2.0
FROM phusion/passenger-full:0.9.12
MAINTAINER Jethro Yu "comet.jc@gmail.com"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Switch to local repo
RUN sed -i -e "s#http://archive.ubuntu.com/ubuntu/#http://free.nchc.org.tw/ubuntu/#" /etc/apt/sources.list
RUN add-apt-repository -s -y 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main'

# Update base image
RUN apt-get update
RUN apt-get install wget unzip devscripts -y

RUN mkdir /deb
WORKDIR /deb

# Initial nginx build tools
RUN apt-get build-dep -y nginx=$NGINX_VERSION
# Update nginx build tools
ENV NGINX_VERSION 1:1.6.1-2.4.0.50~trusty1
RUN apt-get update
RUN apt-get build-dep -y nginx=$NGINX_VERSION

# Download nginx source
RUN apt-get source nginx=$NGINX_VERSION
RUN mv nginx-*/ nginx/

WORKDIR /deb/nginx

# Download ngx_pagespeed source
# check https://developers.google.com/speed/pagespeed/module/build_ngx_pagespeed_from_source for new version
ENV NPS_VERSION 1.8.31.4
RUN wget http://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip
RUN unzip release-${NPS_VERSION}-beta.zip
RUN rm release-${NPS_VERSION}-beta.zip
RUN wget http://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz --progress=dot:giga
RUN tar -xzf ${NPS_VERSION}.tar.gz -C ngx_pagespeed-release-${NPS_VERSION}-beta/
RUN rm ${NPS_VERSION}.tar.gz
RUN mv ngx_pagespeed-release-${NPS_VERSION}-beta debian/modules/

# include pagespeed & passenger module in configure
#RUN \
#  config=`passenger-config --root` && \
#  setting=`grep nginx_module_source_dir $config` && \
#  eval $setting && \
#  sed -i -e "s#^common_configure_flags.*#&\n--add-module=$nginx_module_source_dir' \\'#" debian/rules
RUN \
  echo $nginx_module_source_dir && \
  NGX_PAGESPEED_DIR='$(MODULESDIR)/ngx_pagespeed-release-'"${NPS_VERSION}-beta" && \
  sed -i -e "s#^common_configure_flags.*#&\n--add-module=$NGX_PAGESPEED_DIR \\\#" debian/rules

# Increase the source package version, since this will help you pin the package later.
RUN debchange --nmu "Add PageSpeed-${NPS_VERSION}-beta"

# Build & install nginx
#RUN dpkg-buildpackage -b -uc -us
RUN debuild -eDEB_BUILD_OPTIONS="parallel=4" -i -us -uc -b 

# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
WORKDIR /deb
RUN rm -rf nginx *.changes *.gz *.dsc
