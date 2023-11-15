#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi


echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall MongoDB  \033[0m\n"

cd ~

# install mongodb-org
apt install -y gnupg					> $LOG_FILE 2>&1
curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt update								> $LOG_FILE 2>&1
apt install -y mongodb-org-4			> $LOG_FILE 2>&1
systemctl enable mongod 				> $LOG_FILE 2>&1
systemctl start mongod 					> $LOG_FILE 2>&1

systemctl daemon-reload					> $LOG_FILE 2>&1


echo -en "\033[1;32m============================ \033[0m\n"
