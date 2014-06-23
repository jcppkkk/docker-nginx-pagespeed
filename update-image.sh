#!/bin/bash
PAGESPEED_VER=`curl -s "https://github.com/pagespeed/ngx_pagespeed/releases/" \
	| grep /tag/ | sed -e 's#.*/\(.*\)".*#\1#' | head -1`

sed -e "/^ENV PAGESPEED_VER/s/.*/ENV PAGESPEED_VER 22${PAGESPEED_VER}22/" Dockerfile
