#!/bin/bash
set -e
if [[ $# != 1 ]]; then
    echo Usage: ./nginx-setup.sh project_name;
    exit 1;
fi

# OS config
USER=www-data
GROUP=www-data

# Conda setup
CONDA=/opt/conda

# Project configuration
CONFIG_FILE=10-django-website.conf
SERVER_NAME=_
PROJECT_NAME=$1
BASE_DIR=/var/www
PROJECT_PATH=$BASE_DIR/$PROJECT_NAME
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


# Install nginx
apt-get install nginx

cp ./$CONFIG_FILE $NGINX_TMP_CONF
sed -i "s~\$SERVER_NAME~$SERVER_NAME~g" $NGINX_TMP_CONF
sed -i "s~\$PORT~$PORT~g" $NGINX_TMP_CONF
sed -i "s~\$CLIENT_MAX_BODY_SIZE~$CLIENT_MAX_BODY_SIZE~g" $NGINX_TMP_CONF
sed -i "s~\$PROJECT_PATH~$PROJECT_PATH~g" $NGINX_TMP_CONF
sed -i "s~\$UWSGI_SOCKET~$UWSGI_SOCKET~g" $NGINX_TMP_CONF


# Install uwsgi & django with conda
$CONDA/bin/conda install -yq django uwsgi

# Set up django
mkdir $PROJECT_PATH
$CONDA/bin/django-admin startproject $PROJECT_NAME $PROJECT_PATH

# Set up uwsgi
cp ./uwsgi-config.ini $PROJECT_PATH

touch $UWSGI_SOCKET 
chown $USER:$GROUP $UWSGI_SOCKET

sed -i "s~\$PROJECT_PATH~$PROJECT_PATH~g" $PROJECT_PATH/uwsgi-config.ini
sed -i "s~\$PROJECT_NAME~$PROJECT_NAME~g" $PROJECT_PATH/uwsgi-config.ini
sed -i "s~\$UWSGI_SOCKET~$UWSGI_SOCKET~g" $PROJECT_PATH/uwsgi-config.ini

chown -R $USER:$GROUP $PROJECT_PATH

# Enable project website & start everything
cd $PROJECT_PATH
$CONDA/bin/uwsgi \
    --uid $USER \
    --gid $GROUP \
    --ini $PROJECT_PATH/uwsgi-config.ini \
    --daemonize /var/log/uwsgi-$PROJECT_NAME.log

echo "Linking $NGINX_TMP_CONF to $NGINX_FINAL_CONF"
ln -s $NGINX_TMP_CONF $NGINX_FINAL_CONF
systemctl restart nginx

