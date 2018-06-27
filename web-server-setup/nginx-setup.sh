if [[ $# != 1 ]]; then
    echo Usage: ./nginx-setup.sh project_name;
fi

# OS config
UID=www-data
GID=www-data

# Conda setup
CONDA=/opt/conda

# Project configuration
CONFIG_FILE=10-django-website.conf
SERVER_NAME=_
PROJECT_NAME=$1
PROJECT_PATH=/var/www/$PROJECT_NAME
PORT=80

CLIENT_MAX_BODY_SIZE=75M

# Nginx configuration
NGINX_TMP_CONF=/etc/nginx/sites-available/$CONFIG_FILE
NGINX_FINAL_CONF=/etc/nginx/sites-enabled/$CONFIG_FILE

UWSGI_SOCKET=$PROJECT_DIR/$PROJECT_NAME.sock


# Install nginx
apt-get install nginx

cp ./$CONFIG_FILE $NGINX_TMP_CONF
sed -i "s/\$SERVER_NAME/$SERVER_NAME/g" $NGINX_TMP_CONF
sed -i "s/\$PORT/$PORT/g" $NGINX_TMP_CONF
sed -i "s/\$CLIENT_MAX_BODY_SIZE/$CLIENT_MAX_BODY_SIZE/g" $NGINX_TMP_CONF
sed -i "s/\$PROJECT_DIR/$PROJECT_DIR/g" $NGINX_TMP_CONF
sed -i "s/\$UWSGI_SOCKET/$UWSGI_SOCKET/g" $NGINX_TMP_CONF

ln -s $NGINX_TMP_CONF $NGINX_FINAL_CONF


# Install uwsgi & django with conda
$CONDA/bin/conda install -yq django uwsgi

# Set up uwsgi
mkdir $PROJECT_DIR
cp ./uwsgi-config.ini $PROJECT_PATH

sed -i "s/\$PROJECT_PATH/$PROJECT_PATH/g" $PROJECT_PATH/uwsgi-config.ini
sed -i "s/\$PROJECT_NAME/$PROJECT_NAME/g" $PROJECT_PATH/uwsgi-config.ini
sed -i "s/\$UWSGI_SOCKET/$UWSGI_SOCKET/g" $PROJECT_PATH/uwsgi-config.ini

# Set up django
cd $PROJECT_DIR
django-admin startproject $PROJECT_NAME

# Start everything
$CONDA/bin/uwsgi --uid $UID --gid $GID --ini $PROJECT_PATH/uwsgi-config.ini
systemctl restart nginx

