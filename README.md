# docker-nginx-pagespeed

It's publish at my blog post [Build Nginx http2 + PageSpeed + Passenger on ubuntu 14.04](http://scyu.logdown.com/posts/93686-installing-passenger-nginx-http2-pagespeed-module-on-a-linux-unix-production-server), I use this Dockerfile to test my build steps works or not.

### Build it into Docker container

```
docker build -t jcppkkk/nginx-pagespeed .
```

### Test it

1. **h2** : http2 protocol 
2. **X-Page-Speed** : Page-Speed protocol
3. **Welcome#index** : nginx with passenger ruby server is running

```
docker run --rm -it jcppkkk/nginx-pagespeed bash -c "service nginx start && openssl s_client -connect 127.0.0.1:443 -nextprotoneg '' 2>/dev/null | grep 'Protocols.*h2' && curl -sLkI 'https://127.0.0.1/' | grep 'X-Page-Speed' && curl -sk https://127.0.0.1/ | grep Welcome"
 * Starting Nginx Server...    [ OK ]
Protocols advertised by server: h2, http/1.1
X-Page-Speed: 1.10.33.2-7600
<h1>Welcome#index</h1>
```docker build -t jcppkkk/nginx-pagespeed .
