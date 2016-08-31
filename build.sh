#!/bin/bash
#
# Build NGINX.
#
# References
#
# - https://www.nginx.com/resources/admin-guide/installing-nginx-open-source/
#

set -e

PCRE_V=8.39
rm -rf pcre-*
echo -n "downloading pcre-$PCRE_V... "
wget -O pcre-$PCRE_V.tar.bz2 "http://downloads.sourceforge.net/project/pcre/pcre/$PCRE_V/pcre-$PCRE_V.tar.bz2?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fpcre%2Ffiles%2Fpcre%2F8.39%2F&ts=1472645099&use_mirror=nchc"
echo "ok"

tar -xjf pcre-$PCRE_V.tar.bz2

ZLIB_V=1.2.8
rm -rf zlib-*
echo -n "downloading zlib-$ZLIB_V... "
wget -O zlib-$ZLIB_V.tar.gz http://zlib.net/zlib-$ZLIB_V.tar.gz
echo "ok"
tar -xzf zlib-$ZLIB_V.tar.gz

rm -rf openssl-*
rm -rf OpenSSL_1_0_1t*
echo -n "downloading OpenSSL_1_0_1t.. "
wget https://github.com/openssl/openssl/archive/OpenSSL_1_0_1t.tar.gz
echo "ok"

tar -xzf OpenSSL_1_0_1t.tar.gz

# It's impossble to build nginx statically, see
# http://stackoverflow.com/q/36646145/288089.
# But we staticlly link 3rd party libraries: pcre, zlib, openssl, to make sure
# these versions are what we want.
#    --with-cc-opt="-static -static-libgcc" \
#    --with-ld-opt="-static" \

./auto/configure --prefix=/opt/nginx \
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
    --with-pcre=./pcre-$PCRE_V \
    --with-zlib=./zlib-$ZLIB_V \
    --with-openssl=./openssl-OpenSSL_1_0_1t

make

echo "make done"

# strip binary
echo "stripping binary..."
strip objs/nginx
echo "done"
