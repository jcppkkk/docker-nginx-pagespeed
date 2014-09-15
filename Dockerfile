# DOCKER-VERSION 1.0.1
FROM phusion/passenger-full:0.9.12
MAINTAINER Jethro Yu "comet.jc@gmail.com"

# Set correct environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...
#############################################################

# Switch to local repo
RUN sed -i -e "s#http://archive.ubuntu.com/ubuntu/#http://free.nchc.org.tw/ubuntu/#" /etc/apt/sources.list

# Remove original nginx
#RUN apt-get remove -y nginx-*

# Update base image
RUN apt-get update
RUN apt-get upgrade -y

# Switch ruby version
RUN ruby-switch --set ruby2.0

# Enable nginx
RUN rm -f /etc/service/nginx/down


# Install nginx-PageSpeed
ADD build-nginx/deb /nginx
WORKDIR /nginx
RUN dpkg --force-all --force-confmiss --force-confold -i nginx-extras_*.deb nginx-common_*.deb nginx_*.deb

# Add webapp
#ADD webapp.conf /etc/nginx/sites-enabled/webapp.conf
#RUN mkdir /home/app/webapp

#############################################################
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
