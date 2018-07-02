#!/bin/bash
set -e

CONDA_PKG=/opt/conda/bin

PROJECT_NAME=externaldoc
DOC_SRC_DIR=~/repositories/datapred/docs/
PROJECT_DIR=/var/www/$PROJECT_NAME

WEB_USER=www-data
WEB_GROUP=www-data

# Web server setup
rm -rf $PROJECT_DIR
mkdir $PROJECT_DIR
cp -r ~/repositories/datapred/docs/web/$PROJECT_NAME/* $PROJECT_DIR

# Doc generation
cd ~/repositories/datapred/docs/ && $CONDA_PKG/sphinx-build ./ _build/html 
mkdir $PROJECT_DIR/templates/doc

cd $DOC_SRC_DIR/_build/html
echo "moving files to project templates diretory:"
find . -maxdepth 1 \
    -regex "\.\/[^_.].+$" \
    ! -name objects.inv \
    ! -name searchindex.js \
    ! -name search.html \
    ! -name py-modindex.html \
    -exec cp -r -t $PROJECT_DIR/templates/doc/ {} +

cp -r _static/ _images $PROJECT_DIR
chown -R $WEB_USER:$WEB_GROUP $PROJECT_DIR

sudo $CONDA_PKG/python manage.py collectstatic

