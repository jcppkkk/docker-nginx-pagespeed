# DOCKER-VERSION 1.0.1
FROM	ubuntu:14.04
MAINTAINER Jethro Yu "comet.jc@gmail.com"

RUN echo 'Acquire::http { Proxy "http://128.199.254.75:3142"; };' >> /etc/apt/apt.conf.d/01proxy

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# update base image
RUN apt-get update
RUN apt-get upgrade -y

# install RVM, Ruby, Bundler and passenger
RUN apt-get install -y curl
RUN \curl -L https://get.rvm.io | bash -s stable --auto-dotfiles
ENV PATH /usr/local/rvm/bin:$PATH
RUN rvm install 2.0
RUN rvm all do rvm --default use 2.0
RUN rvm all do gem install bundler --no-ri --no-rdoc
RUN rvm all do gem install passenger --no-ri --no-rdoc


# Install nginx

## Install build tools
RUN apt-get install -y software-properties-common
RUN add-apt-repository -s -y ppa:nginx/stable
RUN apt-get update

## Download nginx source
RUN apt-get build-dep -y nginx-full
RUN \
  mkdir /build && \
  cd /build && \
  apt-get source nginx-full
RUN mv /build/nginx-*/ /build/nginx/

## Download ngx_pagespeed source,
## check https://github.com/pagespeed/ngx_pagespeed/releases for new version
ENV PAGESPEED_VER v1.8.31.4-beta 
ENV PSOL_VER 1.8.31.4

RUN apt-get install wget
RUN wget "https://github.com/pagespeed/ngx_pagespeed/archive/$PAGESPEED_VER.tar.gz" -nv -O - | tar zx -C /build
RUN mv /build/ngx_pagespeed-*/ /build/ngx_pagespeed/
RUN wget "https://dl.google.com/dl/page-speed/psol/$PSOL_VER.tar.gz" -nv -O - | tar xz -C /build/ngx_pagespeed

## Build nginx
apt-get install libcurl4-openssl-dev
RUN rvm all do passenger-install-nginx-module --auto --extra-configure-flags="--error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid --http-log-path=/var/log/nginx/access.log --with-http_ssl_module --with-http_spdy_module --add-module=/usr/local/src/ngx_pagespeed "


#RUN \
#  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
#  chown -R www-data:www-data /var/lib/nginx
#
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Define mountable directories.
#VOLUME ["/data", "/etc/nginx/sites-enabled", "/var/log/nginx"]

# Define working directory.
#WORKDIR /etc/nginx

# Define default command.
#CMD ["nginx"]

# Expose ports.
#EXPOSE 80
#EXPOSE 443
