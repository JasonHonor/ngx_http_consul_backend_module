cd /home/user/go/src/github.com/JasonHonor/ngx_http_consul_backend_module
mkdir -p /home/user/nginx-go/ext
CGO_CFLAGS="-I /home/user/nginx-go/ngx_devel_kit-0.3.1/src" \
    go build \
      -buildmode=c-shared \
      -o /home/user/nginx-go/ext/ngx_http_consul_backend_module.so \
      src/ngx_http_consul_backend_module.go
mkdir /nginx
mkdir -p /nginx/ext

sudo cp /home/user/nginx-go/ext/ngx_http_consul_backend_module.so /nginx/ext/

cd /home/user/nginx-go/nginx-1.19.0
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
    --add-module=/home/user/nginx-go/ngx_devel_kit-0.3.1 \
    --add-module=/home/user/go/src/github.com/JasonHonor/ngx_http_consul_backend_module \
    --http-client-body-temp-path=/nginx/client_temp \
    --http-proxy-temp-path=/nginx/proxy_temp \
    --http-fastcgi-temp-path=/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/nginx/uwsgi_temp \
    --http-scgi-temp-path=/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-openssl=/home/user/nginx-go/openssl-1.1.1g \
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
    --with-file-aio \
    --with-ld-opt='-lunwind-x86_64' \
    --with-cc-opt='-fno-omit-frame-pointer -g -pipe -Wp,-fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic'
make
sudo make install

cd /nginx
