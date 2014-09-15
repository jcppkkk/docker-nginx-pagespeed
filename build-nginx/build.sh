#!/bin/bash

BUILD_DIR=deb
NGINX_VERSION=`curl https://oss-binaries.phusionpassenger.com/apt/passenger/dists/trusty/main/source/Sources.gz \
	| gunzip | grep -A6 'Package: nginx' | grep 'Version:' | cut -d ' ' -f 2`
PAGESPEED_VERSION=`curl -s "https://github.com/pagespeed/ngx_pagespeed/releases/" \
	| grep /tag/ | sed -e 's#.*/v\(.*\)".*#\1#' | head -1 | sed -e 's/-beta//'`

sed -i -e "/^ENV NGINX_VERSION/s/.*/ENV NGINX_VERSION ${NGINX_VERSION}/" \
	-e "/^ENV NPS_VERSION/s/.*/ENV NPS_VERSION ${PAGESPEED_VERSION}/" \
	Dockerfile

echo Nginx: ${NGINX_VERSION}
echo PageSpeed: ${PAGESPEED_VERSION}

rm -rf $BUILD_DIR
docker build -t nginx_pagespeed_builder .
docker run --cidfile="cid" -d nginx_pagespeed_builder
docker cp `cat cid`:/$BUILD_DIR .
docker rm -f `cat cid`
rm -f cid
