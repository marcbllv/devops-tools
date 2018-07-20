#!/bin/bash
set -e
if [[ $# != 1 ]]; then
    echo Usage: $0 project_name;
    exit 1;
fi


# OS config
USER=www-data
GROUP=www-data

# Conda setup
CONDA_BIN=/opt/conda/bin

# Project configuration
PROJECT_NAME=$1
PROJECT_PATH=/var/www/$PROJECT_NAME

UWSGI_RUN_DIR=/run/uwsgi
UWSGI_CONFIG_DIR=/etc/uwsgi
UWSGI_CONFIG_FILE=$UWSGI_CONFIG_DIR/uwsgi-$PROJECT_NAME.ini
UWSGI_SOCKET=$UWSGI_RUN_DIR/uwsgi-$PROJECT_NAME.sock
UWSGI_PID_FILE=$UWSGI_RUN_DIR/uwsgi-$PROJECT_NAME.pid

cd "$(dirname "$0")"

# Set up uwsgi 
mkdir -p $UWSGI_CONFIG_DIR
cp ./uwsgi-config.ini $UWSGI_CONFIG_FILE
chmod 644 $UWSGI_CONFIG_FILE

mkdir -p $UWSGI_RUN_DIR
touch $UWSGI_SOCKET 
chown -R $USER:$GROUP $UWSGI_RUN_DIR

sed -i "s~\$PROJECT_PATH~$PROJECT_PATH~g" $UWSGI_CONFIG_FILE
sed -i "s~\$PROJECT_NAME~$PROJECT_NAME~g" $UWSGI_CONFIG_FILE
sed -i "s~\$UWSGI_SOCKET~$UWSGI_SOCKET~g" $UWSGI_CONFIG_FILE
sed -i "s~\$UWSGI_PID_FILE~$UWSGI_PID_FILE~g" $UWSGI_CONFIG_FILE

# Enable project website & start everything
$CONDA_BIN/uwsgi \
    --uid $USER \
    --gid $GROUP \
    --ini $UWSGI_CONFIG_FILE

