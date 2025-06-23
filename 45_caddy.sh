#!/bin/bash

set -e

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi
if ! [[ $PHP_V ]] ; then PHP_V="8.0" ; fi

if [[ $1 ]] ; then DOMAIN=$1; fi

if [[ $2 ]] ; then PUBLIC_PATH=$2; fi
if [[ $PUBLIC_PATH ]] ; then PUBLIC_PATH=""; fi


#=======================================================#
echo -en "\n\033[1;32m🔧 Встановлення Caddy + PHP $PHP_V \033[0m\n"

apt-get install -y debian-keyring debian-archive-keyring curl > "$LOG_FILE" 2>&1

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt-get update > "$LOG_FILE" 2>&1
apt-get install -y caddy php${PHP_V}-fpm > "$LOG_FILE" 2>&1

systemctl enable php${PHP_V}-fpm --now
systemctl enable caddy --now

echo -en "\n\033[1;32m✅ Встановлення завершено. \033[0m\n"
