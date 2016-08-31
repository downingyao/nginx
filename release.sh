#!/bin/bash
#
# Release nginx package.
#

set -e

function usage() {
    echo "Usage: $0 PACKAGE"
}

if [ -z "$1" ]; then
    echo "please specify release package name (.tar.gz)"
    usage
    exit
fi
PACKAGE="$1"

rm -rf release

mkdir -p release/{sbin,logs}
cp -r conf/ docs/html/ release/
mv release/conf/nginx.conf release/conf/nginx.conf.default
cp objs/nginx release/sbin/

tar -C release -czvf "$PACKAGE" conf html logs sbin
echo "released: $PACKAGE"
