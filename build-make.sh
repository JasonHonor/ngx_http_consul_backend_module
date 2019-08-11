cd /home/user/go/src/github.com/JasonHonor/ngx_http_consul_backend_module
mkdir -p /home/user/nginx-go/ext

cd /home/user/nginx-go/nginx-1.17.2
make
sudo make install

cd /home/user/go/src/github.com/JasonHonor/ngx_http_consul_backend_module

sudo nginx -s stop
sudo nginx
