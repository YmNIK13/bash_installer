#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi
if ! [[ $PHP_V ]] ; then PHP_V="8.0" ; fi

if [[ $1 ]] ; then DOMAIN=$1; fi

if [[ $2 ]] ; then PUBLIC_PATH=$2; fi
if [[ $PUBLIC_PATH ]] ; then PUBLIC_PATH=""; fi


#=======================================================#
echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall NGinx  \033[0m\n"

apt install -y nginx > $LOG_FILE 2>&1


cat <<EOF > /etc/nginx/sites-available/default
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 104.16.0.0/12;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 131.0.72.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2606:4700::/32;
set_real_ip_from 2803:f800::/32;
set_real_ip_from 2405:b500::/32;
set_real_ip_from 2405:8100::/32;
set_real_ip_from 2c0f:f248::/32;
set_real_ip_from 2a06:98c0::/29;
real_ip_header X-Forwarded-For;
EOF


if [[ $DOMAIN ]] ; then
CONFIG_NGINX_FILE="/etc/nginx/sites-available/"$DOMAIN".conf"

cat <<EOF > $CONFIG_NGINX_FILE
server {
    listen 80;
    listen [::]:80;

    server_name $DOMAIN;

    root /var/www/$DOMAIN$PUBLIC_PATH;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php$PHP_V-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}

EOF

	ln -s $CONFIG_NGINX_FILE /etc/nginx/sites-enabled/

	# not
	if ! [ -d /var/www/$DOMAIN ]; then
	    mkdir /var/www/$DOMAIN

	    if [[ $PUBLIC_PATH ]] ; then
	    	mkdir "/var/www/"$DOMAIN$PUBLIC_PATH
	    fi
	fi

fi

systemctl enable nginx  > $LOG_FILE 2>&1
systemctl restart nginx > $LOG_FILE 2>&1

if ! [[ -f /usr/bin/certbot ]] ; then
echo -en "\033[1;32mInstall Cer Bot  \033[0m\n"

apt install -y snapd	> $LOG_FILE 2>&1

snap install core		> $LOG_FILE 2>&1
snap refresh core		> $LOG_FILE 2>&1

snap install --classic certbot	> $LOG_FILE 2>&1

ln -s /snap/bin/certbot /usr/bin/certbot
fi

if [[ $DOMAIN ]] ; then
	/usr/bin/certbot --nginx --expand -d $DOMAIN -d www.$DOMAIN -n --agree-tos --email admin_ua@$DOMAIN > $LOG_FILE 2>&1


    echo -en "\n\033[1;33m---------------------------- \033[0m\n"
    echo -en "\033[1;33mЕсли сертификат не создался - выполните команду: \033[0m\n"
    echo -en "\033[1;36m/usr/bin/certbot --nginx --expand -d $DOMAIN -d www.$DOMAIN -n --agree-tos --email admin_ua@$DOMAIN\033[0m\n"
    echo -en "\033[1;33m---------------------------- \033[0m\n"
fi

echo -en "\033[1;32m============================ \033[0m\n"
