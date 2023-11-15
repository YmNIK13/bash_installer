#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi

if [[ $1 ]] ; then NODE_V=$1 ; fi
if ! [[ $NODE_V ]] ; then NODE_V=node ; fi


#=======================================================#
echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall Node JS $NODE_V  \033[0m\n"


curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash	> $LOG_FILE 2>&1
source ~/.profile

nvm install $NODE_V


echo -en "\033[1;33m Install PM2 \033[0m\n"

npm install pm2@latest -g
pm2 startup systemd

env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u www-data --hp /var/wwww

pm2 save

systemctl start pm2-www-data

echo -en "\033[1;32m============================ \033[0m\n"
