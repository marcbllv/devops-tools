#!/bin/bash
set -e

if [[ $# < 1 ]]; then
    echo "Usage: ./postgres-setup.sh new_user"
    exit 1
fi

USER=$1

read -s -p "Enter user password: " PASSWD_A
echo
read -s -p "Repeat user password: " PASSWD_B
echo
while [[ $PASSWD_A != $PASSWD_B ]]; do
    echo "Passwords don't match, please pay attention to what you type!..."
    read -s -p "Enter user password: " PASSWD_A
    echo
    read -s -p "Repeat user password: " PASSWD_B
    echo
done

sudo -i -u postgres -- psql postgres -c "CREATE USER $USER WITH \
                                         CREATEDB \
                                         ENCRYPTED PASSWORD '$PASSWD_A' \
                                         VALID UNTIL 'infinity';"

