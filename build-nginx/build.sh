#!/bin/bash
PAGESPEED_VER=`curl -s "https://github.com/pagespeed/ngx_pagespeed/releases/" \
	| grep /tag/ | sed -e 's#.*/v\(.*\)".*#\1#' | head -1 | sed -e 's/-beta//'`

echo ${PAGESPEED_VER}
sed -i -e "/^ENV PAGESPEED_VER/s/.*/ENV PAGESPEED_VER ${PAGESPEED_VER}/" Dockerfile

rm -rf deb
docker build -t nginx_pagespeed_builder .
docker run --cidfile="cid" nginx_pagespeed_builder
docker cp `cat cid`:/build .
mv build deb
docker rm `cat cid`
rm -f cid
