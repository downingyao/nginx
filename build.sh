#!/bin/bash
#
# Build NGINX.
#

set -e

apt-get install libpcre3-dev -y

if ! test -f OpenSSL_1_0_1t.tar.gz; then
    wget https://github.com/openssl/openssl/archive/OpenSSL_1_0_1t.tar.gz
fi

rm -rf openssl-*
tar -xzvf OpenSSL_1_0_1t.tar.gz

./auto/configure --prefix=/opt/nginx \
    --with-cc-opt="-static -static-libgcc" \
    --with-ld-opt="-static" \
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
    --with-openssl=./openssl-OpenSSL_1_0_1t

make

# make sure binary is statically linked
file objs/nginx | grep "statically linked"
