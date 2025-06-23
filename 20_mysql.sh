#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi


echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall MySql  \033[0m\n"

apt-get install -y mysql-server	> $LOG_FILE 2>&1


echo -en "\033[1;33m Setting MySQL  \033[0m\n"

if [[ $MYS_NAME_DB ]] ; then
	mysql -e "CREATE DATABASE $MYS_NAME_DB;"

	echo -en "\033[1;33m CREATE DATABASE: $MYS_NAME_DB \033[0m\n"
fi

if [[ $MYS_NAME_USER && $MYS_PASS_USER ]] ; then
	mysql -e "CREATE USER '$MYS_NAME_USER'@'localhost' IDENTIFIED BY '$MYS_PASS_USER';"
	mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$MYS_NAME_USER'@'localhost' WITH GRANT OPTION;"

	mysql -e "FLUSH PRIVILEGES;"

	echo -en "\033[1;33m CREATE USER: $MYS_NAME_USER \n PASS: $MYS_PASS_USER \033[0m\n"
fi

systemctl restart mysql

echo -en "\033[1;32m============================ \033[0m\n"
