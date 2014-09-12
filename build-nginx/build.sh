#!/bin/bash

NGINX_VERSION=`xidel https://launchpad.net/~nginx/+archive/ubuntu/stable?field.series_filter=trusty  --extract  "//table[@id='packages_list']//td[2]"`
PAGESPEED_VERSION=`curl -s "https://github.com/pagespeed/ngx_pagespeed/releases/" \
	| grep /tag/ | sed -e 's#.*/v\(.*\)".*#\1#' | head -1 | sed -e 's/-beta//'`

sed -i -e "/^ENV NGINX_VERSION/s/.*/ENV NGINX_VERSION ${NGINX_VERSION}/" \
	-e "/^ENV NPS_VERSION/s/.*/ENV NPS_VERSION ${PAGESPEED_VERSION}/" \
	Dockerfile

echo Nginx: ${NGINX_VERSION}
echo PageSpeed: ${PAGESPEED_VERSION}

rm -rf deb
docker build -t nginx_pagespeed_builder .
docker run --cidfile="cid" nginx_pagespeed_builder
docker cp `cat cid`:/build .
mv build deb
docker rm `cat cid`
rm -f cid
