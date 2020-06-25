FROM centos:7

WORKDIR /nginx

ADD nginx /nginx

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

RUN yum install libunwind -y
#RUN mkdir -p /etc/nginx/ext

#RUN ln -s /nginx/ext/ngx_http_consul_backend_module.so /etc/nginx/ext/ngx_http_consul_backend_module.so

#ENTRYPOINT ["/nginx/nginx" "-g" "daemon off;"]
CMD ["/nginx/nginx", "-g", "daemon off;"]
