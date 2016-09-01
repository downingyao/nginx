#!/bin/bash
#
# See http://nginx.org/en/docs/control.html#upgrade.
#

ROOT=$(unset CDPATH && cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function hot_upgrade() {
    local pidfile=$1
    local oldpidfile=$1.oldbin

    # Check nginx is in upgrading or not?
    if test -f $oldpidfile; then
        echo "Nginx is in upgrading, ignored."
        exit 0
    fi

    # Get current pid.
    local pid=$(cat $pidfile)
    if [[ -z $pid ]]; then
        echo "pid not found, please manual operation."
        exit 2
    fi

    # Send USR2 to current master process.
    kill -USR2 $pid

    sleep 1

    # Check new nginx master started?
    if ! test -f $pidfile; then
        echo "New nginx process not started."
        exit 1
    fi

    # 
    local oldpid=$(cat $oldpidfile)
    if [[ -z $oldpid ]]; then
        echo "old pid not found, please manual operation."
        exit 2
    fi

    # Send WINCH signal to old master process, it will send messages to its worker
    # processes, requesting them to shut down gracefully, and they will start to
    # exit.
    kill -WINCH $oldpid

    # Send QUIT signal to old master 
    kill -QUIT $oldpid

    echo "Old master ($oldpid) is told to quit."
}

# nginx
$ROOT/sbin/nginx -t
if [ $? -ne 0 ]; then
    echo "Nginx configuration test failed."
    exit
fi
hot_upgrade $ROOT/logs/nginx.pid
