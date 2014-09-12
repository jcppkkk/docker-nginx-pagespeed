# DOCKER-VERSION 1.2.0
FROM ubuntu:14.04
MAINTAINER Jethro Yu "comet.jc@gmail.com"

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Switch to local repo
RUN sed -i -e "s#http://archive.ubuntu.com/ubuntu/#http://free.nchc.org.tw/ubuntu/#" /etc/apt/sources.list

# Update base image
RUN apt-get update -qq
RUN apt-get install software-properties-common -y
RUN add-apt-repository -s -y ppa:nginx/stable
RUN apt-get update -qq
RUN apt-get upgrade -y

# Install nginx build tools
# Download nginx source
RUN apt-get build-dep -y nginx
mkdir /build
WORKDIR /build
RUN apt-get source nginx
RUN mv nginx-*/ nginx/

# Download ngx_pagespeed source
RUN apt-get install -y wget unzip
# check https://developers.google.com/speed/pagespeed/module/build_ngx_pagespeed_from_source for new version
ENV NPS_VERSION 1.8.31.4
RUN wget http://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip
RUN unzip release-${NPS_VERSION}-beta.zip
RUN rm release-${NPS_VERSION}-beta.zip
RUN wget http://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz --progress=dot:giga
RUN tar -xzvf ${NPS_VERSION}.tar.gz -C ngx_pagespeed-release-${NPS_VERSION}-beta/
RUN rm ${NPS_VERSION}.tar.gz
RUN mv ngx_pagespeed-release-${NPS_VERSION}-beta nginx/debian/modules/

# include pagespeed & passenger module in configure
#RUN \
#  config=`passenger-config --root` && \
#  setting=`grep nginx_module_source_dir $config` && \
#  eval $setting && \
#  sed -i -e "s#^common_configure_flags.*#&\n--add-module=$nginx_module_source_dir' \\'#" nginx/debian/rules
RUN \
  echo $nginx_module_source_dir && \
  NGX_PAGESPEED_DIR='$(MODULESDIR)/ngx_pagespeed-release-${NPS_VERSION}-beta' && \
  sed -i -e "s#^common_configure_flags.*#&\n--add-module=$NGX_PAGESPEED_DIR' \\'#" nginx/debian/rules

# Increase the source package version, since this will help you pin the package later.
RUN sed -i -e "1 s/)/-speed-passenger)/" nginx/debian/changelog

# Build & install nginx
WORKDIR /build/nginx
RUN dpkg-buildpackage -b

#############################################################
# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
WORKDIR /build
RUN rm -rf nginx *.changes *.gz *.dsc
