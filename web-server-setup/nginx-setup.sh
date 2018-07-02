#!/bin/bash
set -e
if [[ $# != 1 ]]; then
    echo Usage: $0 project_name;
    exit 1;
fi

# Project configuration
SERVER_NAME=_
PROJECT_NAME=$1
BASE_DIR=/var/www
PROJECT_PATH=$BASE_DIR/$PROJECT_NAME
CONFIG_FILE=10-django-$PROJECT_NAME.conf
PORT=80

CLIENT_MAX_BODY_SIZE=75M

# Nginx configuration
NGINX_TMP_CONF=/etc/nginx/sites-available/$CONFIG_FILE
NGINX_FINAL_CONF=/etc/nginx/sites-enabled/$CONFIG_FILE

UWSGI_SOCKET=$PROJECT_PATH/$PROJECT_NAME.sock

echo Creating project \"$PROJECT_NAME\"


if [ -f $NGINX_TMP_CONF ] || [ -f $NGINX_FINAL_CONF ]; then
    echo Project config file $CONFIG_FILE already exists in nginx config.
    exit 1
fi

cp ./$CONFIG_FILE $NGINX_TMP_CONF
sed -i "s~\$SERVER_NAME~$SERVER_NAME~g" $NGINX_TMP_CONF
sed -i "s~\$PORT~$PORT~g" $NGINX_TMP_CONF
sed -i "s~\$CLIENT_MAX_BODY_SIZE~$CLIENT_MAX_BODY_SIZE~g" $NGINX_TMP_CONF
sed -i "s~\$PROJECT_PATH~$PROJECT_PATH~g" $NGINX_TMP_CONF
sed -i "s~\$UWSGI_SOCKET~$UWSGI_SOCKET~g" $NGINX_TMP_CONF


echo "Linking $NGINX_TMP_CONF to $NGINX_FINAL_CONF"
ln -s $NGINX_TMP_CONF $NGINX_FINAL_CONF
systemctl restart nginx

