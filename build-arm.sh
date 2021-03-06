cd ~/go/src/github.com/JasonHonor/ngx_http_consul_backend_module
mkdir -p /root/nginx-go/ext
CGO_CFLAGS="-I /root/nginx-go/ngx_devel_kit-0.3.1/src" \
    go build \
      -buildmode=c-shared \
      -o /root/nginx-go/ext/ngx_http_consul_backend_module.so \
      src/ngx_http_consul_backend_module.go

rm /nginx -rf
mkdir /nginx
mkdir -p /nginx/ext

sudo cp /root/nginx-go/ext/ngx_http_consul_backend_module.so /nginx/ext/

cd /root/nginx-go/nginx-1.17.2
CFLAGS="-g " \
    ./configure \
    --with-debug \
    --prefix=/nginx \
    --sbin-path=/nginx \
    --conf-path=/nginx/nginx.conf \
    --error-log-path=/nginx/logs/error.log \
    --http-log-path=/nginx/logs/access.log \
    --pid-path=/nginx/nginx.pid \
    --lock-path=/nginx/nginx.lock \
    --add-module=/root/nginx-go/ngx_devel_kit-0.3.1 \
    --add-module=/root/go/src/github.com/JasonHonor/ngx_http_consul_backend_module \
    --http-client-body-temp-path=/nginx/client_temp \
    --http-proxy-temp-path=/nginx/proxy_temp \
    --http-fastcgi-temp-path=/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/nginx/uwsgi_temp \
    --http-scgi-temp-path=/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-mail \
    --with-mail_ssl_module \
#--with-ld-opt='-lunwind-aarch64' \
    --with-cc-opt='-fno-omit-frame-pointer -g -pipe -Wp,-fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' 

make

sudo make install

cd /nginx

