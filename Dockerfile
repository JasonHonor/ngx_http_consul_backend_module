FROM golang:1.9

WORKDIR /nginx

ADD nginx /nginx

RUN mkdir -p /etc/nginx/ext

RUN ln -s /nginx/ext/ngx_http_consul_backend_module.so /etc/nginx/ext/ngx_http_consul_backend_module.so

ENTRYPOINT ["/nginx/nginx" "-g" "daemon off;"]
