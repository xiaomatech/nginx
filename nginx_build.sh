#!/usr/bin/env bash

build_dir="/tmp/soft"
nginx_version="1.12.0"

yum install -y gd-devel pcre-devel libwebp-devel openssl-devel readline-devel luajit-devel GeoIP-devel libxml2-devel libxslt-devel libwebp libxslt libxml2 readline gd GeoIP luajit openssl

mkdir $build_dir && cd $build_dir
wget http://nginx.org/download/nginx-$nginx_version.tar.gz && tar -zxvf nginx-$nginx_version.tar.gz
wget https://github.com/zebrafishlabs/nginx-statsd/archive/master.zip -O nginx-statsd-master.zip && unzip nginx-statsd-master.zip
wget https://github.com/vozlt/nginx-module-vts/archive/master.zip -O nginx-module-vts-master.zip && unzip nginx-module-vts-master.zip
wget https://github.com/weibocom/nginx-upsync-module/archive/master.zip -O nginx-upsync-module-master.zip && unzip nginx-upsync-module-master.zip
wget https://github.com/alibaba/nginx-http-concat/archive/master.zip -O nginx-http-concat-master.zip && unzip nginx-http-concat-master.zip
wget https://github.com/alibaba/nginx-http-sysguard/archive/master.zip -O nginx-http-sysguard-master.zip && unzip nginx-http-sysguard-master.zip
wget https://github.com/cubicdaiya/ngx_dynamic_upstream/archive/master.zip -O ngx_dynamic_upstream-master.zip && unzip ngx_dynamic_upstream-master.zip
wget https://github.com/FRiCKLE/ngx_cache_purge/archive/master.zip -O ngx_cache_purge-master.zip && unzip ngx_cache_purge-master.zip
wget https://github.com/xiaomatech/nginx-http-trim/archive/master.zip -O nginx-http-trim-master.zip && unzip nginx-http-trim-master.zip
wget https://github.com/xiaokai-wang/nginx_upstream_check_module/archive/master.zip -O nginx_upstream_check_module-master.zip && unzip nginx_upstream_check_module-master.zip
wget https://github.com/openresty/lua-nginx-module/archive/master.zip -O lua-nginx-module-master.zip && unzip lua-nginx-module-master.zip
wget https://github.com/simpl/ngx_devel_kit/archive/master.zip -O ngx_devel_kit-master.zip && unzip ngx_devel_kit-master.zip
#patch sysguard
cd nginx-$nginx_version

wget https://raw.githubusercontent.com/alibaba/nginx-http-sysguard/master/nginx_sysguard_1.3.9.patch -O nginx_sysguard.patch
patch -p1 < ./nginx_sysguard.patch
wget https://raw.githubusercontent.com/yaoweibin/nginx_upstream_check_module/master/check_1.11.5%2B.patch -O check.patch
patch -p0 < ./check.patch

./configure --prefix=/opt/nginx --with-ld-opt=-lwebp --user=nobody --group=nobody --pid-path=/var/run/nginx.pid \
--error-log-path=/data/logs/nginx/error.log --http-log-path=/data/logs/nginx/http.log --http-client-body-temp-path=/data/nginx/client_body_temp \
--http-proxy-temp-path=/data/nginx/proxy_temp --http-fastcgi-temp-path=/data/nginx/fastcgi_temp --http-uwsgi-temp-path=/data/nginx/uwsgi_temp \
--http-scgi-temp-path=/data/nginx/scgi_temp  --with-pcre-jit --with-http_ssl_module --with-threads --with-file-aio --with-http_realip_module \
--with-pcre-jit --with-http_ssl_module --with-http_image_filter_module --with-http_geoip_module --with-http_sub_module --with-http_dav_module \
--with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module \
--with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module \
--with-http_v2_module --with-stream --with-stream_ssl_module --with-stream_realip_module --with-stream_geoip_module --with-stream_ssl_preread_module \
--add-module=$build_dir/nginx-module-vts-master --add-module=$build_dir/nginx-upsync-module-master \
--add-module=$build_dir/ngx_cache_purge-master  --add-module=$build_dir/nginx-http-concat-master --add-module=$build_dir/nginx-http-trim-master --add-module=$build_dir/nginx-http-sysguard-master \
--add-module=$build_dir/nginx-statsd-master --add-module=$build_dir/ngx_dynamic_upstream-master --add-module=$build_dir/ngx_devel_kit-master \
--add-module=$build_dir/nginx_upstream_check_module-master --add-module=$build_dir/lua-nginx-module-master

make && make install

#rm -rf $build_dir

cd ~
#wget https://raw.githubusercontent.com/xiaomatech/nginx/master/nginx.init -O /etc/init.d/nginx
#fpm -f -s dir -t rpm -v $nginx_version -n nginx -C /opt/nginx --rpm-init /etc/init.d/nginx --prefix /opt/nginx -d libpng -d libwebp -d openssl -d pcre -d readline -d gd -d GeoIP -d libxml2 -d libxslt  -d luajit

