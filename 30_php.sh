#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi

if [[ $1 ]] ; then PHP_V=$1 ; fi
if ! [[ $PHP_V ]] ; then PHP_V=8.0 ; fi


#=======================================================#
echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall PHP $PHP_V  \033[0m\n"

add-apt-repository -y ppa:ondrej/php	> $LOG_FILE 2>&1
apt-get update	> $LOG_FILE 2>&1

echo -en "\033[1;33m Install PHP Common \033[0m\n"
apt-get install -y php$PHP_V-curl php$PHP_V-cgi php$PHP_V-bcmath	> $LOG_FILE 2>&1
apt-get install -y php$PHP_V-zip php$PHP_V-mbstring php$PHP_V-xml php$PHP_V-xmlrpc	> $LOG_FILE 2>&1

echo -en "\033[1;33m Install PHP DB \033[0m\n"
apt-get install -y php$PHP_V-pdo php$PHP_V-intl > $LOG_FILE 2>&1

echo -en "\033[1;33m Install PHP Graphics \033[0m\n"
apt-get install -y php$PHP_V-gd		> $LOG_FILE 2>&1
apt-get install -y php$PHP_V-imagick	> $LOG_FILE 2>&1

echo -en "\033[1;33m Install PHP Dev \033[0m\n"
apt-get install -y php$PHP_V-dev	> $LOG_FILE 2>&1


for file in $(ls -a) ; do 
	if [[ $file =~ "mysql" ]]; then
		echo -en "\033[1;33m Install PHP MySQL \033[0m\n"

		apt-get install -y php$PHP_V-mysql	> $LOG_FILE 2>&1
	fi

	if [[ $file =~ "postgre" ]]; then
		echo -en "\033[1;33m Install PHP Postgre \033[0m\n"

		apt-get install -y php$PHP_V-pgsql	> $LOG_FILE 2>&1
	fi

	if [[ $file =~ "mongo" ]]; then
		echo -en "\033[1;33m Install PHP Mongo \033[0m\n"

		apt-get install -y php-pear			> $LOG_FILE 2>&1
		pecl install mongodb			> $LOG_FILE 2>&1
		echo "extension=mongodb.so" | sudo tee -a /etc/php/$PHP_V/mods-available/mongodb.ini

		phpenmod mongodb
	fi

	if [[ $file =~ "redis" ]]; then
		echo -en "\033[1;33m Install PHP Redis \033[0m\n"
		apt-get install -y php$PHP_V-redis	> $LOG_FILE 2>&1
		phpenmod redis	> $LOG_FILE 2>&1
	fi

done


echo -en "\033[1;33m Install PHP Server \033[0m\n"
apt-get install -y php$PHP_V apache2- apache2-bin-	> $LOG_FILE 2>&1
apt-get install -y php$PHP_V-fpm	> $LOG_FILE 2>&1

systemctl enable php$PHP_V-fpm	> $LOG_FILE 2>&1
systemctl restart php$PHP_V-fpm	> $LOG_FILE 2>&1


echo -en "\033[1;33m Install Composer  \033[0m\n"
curl -sS https://getcomposer.org/installer | php	> $LOG_FILE 2>&1
mv composer.phar /usr/local/bin/composer	> $LOG_FILE 2>&1


echo -en "\033[1;32m============================ \033[0m\n"
