docker build -t nginx_pagespeed_builder .
docker run --cidfile="cid" nginx_pagespeed_builder
docker cp `cat cid`:/build .
mv build deb
docker rm `cat cid`
rm -f cid
