cd /home/user/go/src/github.com/JasonHonor/ngx_http_consul_backend_module
mkdir -p /home/user/nginx-go/ext
CGO_CFLAGS="-I /home/user/nginx-go/ngx_devel_kit-0.3.1/src" \
    go build \
      -buildmode=c-shared \
      -o /home/user/nginx-go/ext/ngx_http_consul_backend_module.so \
      src/ngx_http_consul_backend_module.go
sudo cp /home/user/nginx-go/ext/ngx_http_consul_backend_module.so /etc/nginx/ext/

cd /home/user/nginx-go/nginx-1.17.2
CFLAGS="-g " \
    ./configure \
    --with-debug \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --add-module=/home/user/nginx-go/ngx_devel_kit-0.3.1 \
    --add-module=/home/user/go/src/github.com/JasonHonor/ngx_http_consul_backend_module \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
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
    --with-file-aio \
    --with-ld-opt='-lunwind-x86_64' \
    --with-cc-opt='-fno-omit-frame-pointer -g -pipe -Wp,-fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic'
make
sudo make install

cd /home/user/go/src/github.com/JasonHonor/ngx_http_consul_backend_module
