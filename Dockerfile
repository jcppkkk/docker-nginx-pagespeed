# DOCKER-VERSION 1.9.1
FROM ubuntu:14.04
MAINTAINER Jethro Yu "comet.jc@gmail.com"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]


# ...put your own build instructions here...
#############################################################

ENV DEBIAN_FRONTEND=noninteractive \
	HOME=/root \
	PATH=/usr/local/rvm/bin:$PATH \
	NPS_VERSION=1.10.33.2 \
	NGINX_VERSION=1.9.9
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
	echo 'APT::Get::Clean=always;' >> /etc/apt/apt.conf.d/99AutomaticClean
RUN apt-get update
RUN apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev unzip wget curl libcurl4-openssl-dev
WORKDIR /root

# ngx_pagespeed source
RUN wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip && \
	unzip release-${NPS_VERSION}-beta.zip && \
	rm release-${NPS_VERSION}-beta.zip && \
	cd ngx_pagespeed-release-${NPS_VERSION}-beta/ && \
	wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
	tar -xzf ${NPS_VERSION}.tar.gz && \
	rm ${NPS_VERSION}.tar.gz

# nginx source
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
	tar -xzf nginx-${NGINX_VERSION}.tar.gz && \
	rm nginx-${NGINX_VERSION}.tar.gz

# rvm
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
	curl -L https://get.rvm.io | /bin/bash -s stable && \
	echo 'source /etc/profile.d/rvm.sh' >> /etc/profile && \
	echo 'source /etc/profile.d/rvm.sh' >> /root/.bashrc && \
	rvm requirements && \
	rvm install 2.0.0 && \
	bash -l -c "rvm use --default 2.0.0 && \
	gem install passenger --no-rdoc --no-ri"
RUN apt-get install -y libcurl4-openssl-dev && \
	adduser --system --no-create-home --disabled-login --disabled-password --group nginx && \
	usermod -g www-data nginx && \
	mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled /var/cache/nginx && \
	bash -l -c "rvmsudo passenger-install-nginx-module --auto \
	--nginx-source-dir=$HOME/nginx-${NGINX_VERSION} \
	--extra-configure-flags=\"\
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log --group=nginx \
	--http-client-body-temp-path=/var/cache/nginx/client_temp \
	--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
	--http-log-path=/var/log/nginx/access.log \
	--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
	--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
	--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
	--lock-path=/var/run/nginx.lock --pid-path=/var/run/nginx.pid \
	--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --user=nginx \
	--with-file-aio --with-http_addition_module \
	--with-http_auth_request_module --with-http_dav_module \
	--with-http_flv_module --with-http_gunzip_module \
	--with-http_gzip_static_module --with-http_mp4_module \
	--with-http_random_index_module --with-http_realip_module \
	--with-http_secure_link_module --with-http_slice_module \
	--with-http_ssl_module --with-http_stub_status_module \
	--with-http_sub_module --with-http_v2_module --with-ipv6 --with-mail \
	--with-mail_ssl_module --with-stream --with-stream_ssl_module \
	--with-threads --with-cc-opt='-g -O2 -fstack-protector \
	--param=ssp-buffer-size=4 -Wformat -Werror=format-security \
	-Wp,-D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions \
	-Wl,-z,relro -Wl,--as-needed' \
	--add-module=$HOME/ngx_pagespeed-release-${NPS_VERSION}-beta\""
ADD https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx /etc/init.d/nginx
ADD nginx.service.patch nginx.conf.patch /
RUN chmod +x /etc/init.d/nginx && \
	patch -p0 /etc/init.d/nginx < /nginx.service.patch && \
	update-rc.d -f nginx defaults && \
	patch -p0 /etc/nginx/nginx.conf < /nginx.conf.patch && \
	openssl req -subj '/CN=domain.com/O=My Company Name LTD./C=US' -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/nginx/cert.key -out /etc/nginx/cert.pem
RUN cd /var/ && \
	apt-get install nodejs -y && \
	bash -l -c 'gem install bundler rails --no-rdoc --no-ri && \
	rails new www && \
	cd /var/www && \
	sed -i "s/secret_key_base.*/secret_key_base: `RAILS_ENV=production rake secret`/" config/secrets.yml && \
	bundle install && \
	rails generate controller welcome index && \
	sed -i "s/# root/root/" config/routes.rb && \
	chown -R nginx:nginx /var/www'
