#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi


echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall PostgreSQL  \033[0m\n"

sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'	> $LOG_FILE 2>&1

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -	> $LOG_FILE 2>&1

apt-get update	> $LOG_FILE 2>&1

apt -y install postgresql	> $LOG_FILE 2>&1


if [[ $PGS_NAME_DB ]] ; then
	su - postgres -c "psql -d postgres -c \"CREATE DATABASE $PGS_NAME_DB;\""
	echo -en "\033[1;33m CREATE DATABASE: $PGS_NAME_DB \033[0m\n"

fi


if [[ $PGS_NAME_USER && $PGS_NAME_PASS ]] ; then
	su - postgres -c "psql -d postgres -c \"CREATE USER $PGS_NAME_USER WITH ENCRYPTED PASSWORD '$PGS_NAME_PASS';\""

	echo -en "\033[1;33m CREATE USER: $PGS_NAME_USER \n PASS: $PGS_NAME_PASS \033[0m\n"

	if [[ $PGS_NAME_DB ]] ; then
		su - postgres -c "psql -d postgres -c \"GRANT ALL PRIVILEGES ON DATABASE $PGS_NAME_DB TO $PGS_NAME_USER;\""
		su - postgres -c "psql -d postgres -c \"ALTER DATABASE $PGS_NAME_DB OWNER TO $PGS_NAME_USER;\""
		
		su - postgres -c "psql -d $PGS_NAME_DB -c \"GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $PGS_NAME_USER;\""
		su - postgres -c "psql -d $PGS_NAME_DB -c \"GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO $PGS_NAME_USER;\""
		su - postgres -c "psql -d $PGS_NAME_DB -c \"GRANT ALL ON SCHEMA public TO $PGS_NAME_USER;\""
	fi
	
	echo -en "\033[1;33m GRANT ALL PRIVILEGES '$PGS_NAME_DB' FOR USER '$PGS_NAME_USER' \033[0m\n"

	PGS_PATH_CONF=$(su - postgres -c 'psql -d postgres -c "SHOW config_file;"' | grep -E -o '|\/.*\/|' )

	if [[ -f $PGS_PATH_CONF"pg_hba.conf" ]]; then
		echo "local    $PGS_NAME_DB            $PGS_NAME_USER                            md5" | cat - $PGS_PATH_CONF"pg_hba.conf" > $PGS_PATH_CONF"temp" 
		mv $PGS_PATH_CONF"temp" $PGS_PATH_CONF"pg_hba.conf"
	fi
fi

systemctl restart postgresql

