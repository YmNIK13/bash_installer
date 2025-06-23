#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi
if ! [[ $PHP_V ]] ; then PHP_V="8.0" ; fi

if [[ $1 ]] ; then DOMAIN=$1; fi

if [[ $2 ]] ; then PUBLIC_PATH=$2; fi
if [[ $PUBLIC_PATH ]] ; then PUBLIC_PATH=""; fi


#=======================================================#
SITES_DIR="/var/www"
CADDYFILE="/etc/caddy/Caddyfile"
PHP_SOCKET="unix//run/php/php${PHP_V}-fpm.sock"

#=======================================================#
echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall Caddy + PHP $PHP_V  \033[0m\n"

apt install -y debian-keyring debian-archive-keyring curl > "$LOG_FILE" 2>&1

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
  | tee /etc/apt/sources.list.d/caddy-stable.list
apt update > "$LOG_FILE" 2>&1
apt install -y caddy php${PHP_V}-fpm > "$LOG_FILE" 2>&1

systemctl enable php${PHP_V}-fpm
systemctl restart php${PHP_V}-fpm
systemctl enable caddy
systemctl restart caddy

#=======================================================#
echo -en "\n\033[1;32mГенерація Caddyfile з авто-доменами \033[0m\n"

> "$CADDYFILE"

for domain_path in "$SITES_DIR"/*; do
    domain=$(basename "$domain_path")

    for subdir in "$domain_path"/*; do
        [ -d "$subdir" ] || continue
        sub=$(basename "$subdir")

        # Пропускаємо, якщо немає index
        if [[ ! -f "$subdir/index.html" && ! -f "$subdir/index.php" ]]; then
            echo "⏭️  Пропущено: $sub.$domain — нема index"
            continue
        fi

        # Повний домен
        if [[ "$sub" == "www" ]]; then
            full_domain="$domain"
        else
            full_domain="$sub.$domain"
        fi

        # Уникнення дублювань
        if grep -q "$full_domain" "$CADDYFILE"; then
            echo "⚠️  Пропущено: $full_domain — вже є"
            continue
        fi

        echo "✅ Додаємо: $full_domain → $subdir"

        cat >> "$CADDYFILE" <<EOF
$full_domain {
    root * $subdir
    php_fastcgi $PHP_SOCKET
    file_server
}
EOF

    done
done

echo -en "\n\033[1;36m🧪 Перевірка Caddyfile... \033[0m\n"
caddy validate

echo -en "\n\033[1;32m🔁 Перезапуск Caddy... \033[0m\n"
systemctl reload caddy

echo -en "\n\033[1;32m✅ Сертифікати будуть створені автоматично при першому запиті. \033[0m\n"
echo -en "\033[1;32m============================ \033[0m\n"
