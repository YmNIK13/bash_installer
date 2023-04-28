#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi


echo -en "\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall SuperVisor  \033[0m\n"

apt install -y supervisor > $LOG_FILE 2>&1


if [[ $DOMAIN ]] ; then

	CONFIG_SUPERVISOR_FILE="/etc/supervisor/conf.d/laravel_"$DOMAIN".conf"

cat <<EOF > $CONFIG_SUPERVISOR_FILE
[program:laravel_$DOMAIN]
# название воркера, можно через подчеркивание задавать разные конфи
# для многопоточности
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/$DOMAIN/artisan queue:work redis --queue=default --sleep=3 --tries=3 --timeout=60 --max-jobs=1000 --max-time=3600
autostart=true
autorestart=true
# пользователь под которым запускать очередь
user=www-data
# количество потоков
numprocs=1
redirect_stderr=true
stdout_logfile=/var/www/$DOMAIN/storage/logs/worker.log

EOF

	# обновляем конфигурацию
	supervisorctl reread

	# обновляем сам supervisor
	supervisorctl update

fi


echo -en "\033[1;32m============================ \033[0m\n"