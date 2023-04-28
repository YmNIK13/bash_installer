#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi

PGS_NAME_DB="pegasus"
PGS_NAME_USER="lara"
PGS_NAME_PASS="lara"

echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall PostgreSQL  \033[0m\n"

#sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'	> $LOG_FILE 2>&1

#wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -	> $LOG_FILE 2>&1

#apt update	> $LOG_FILE 2>&1

#apt -y install postgresql	> $LOG_FILE 2>&1


if [[ $PGS_NAME_DB ]] ; then

	su - postgres -c "psql -d postgres -c \"CREATE DATABASE $PGS_NAME_DB;\""
	echo -en "\033[1;33m CREATE DATABASE: $PGS_NAME_DB \033[0m\n"

fi


if [[ $PGS_NAME_USER && $PGS_NAME_PASS ]] ; then

	su - postgres -c "psql -d postgres -c \"CREATE USER $PGS_NAME_USER WITH ENCRYPTED PASSWORD '$PGS_NAME_PASS';\""
	su - postgres -c "psql -d postgres -c \"GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $PGS_NAME_USER;\""

	if [[ $PGS_NAME_DB ]] ; then
		su - postgres -c "psql -d postgres -c \"GRANT ALL PRIVILEGES ON DATABASE $PGS_NAME_DB TO $PGS_NAME_USER;\""
	fi

	echo -en "\033[1;33m CREATE USER: $PGS_NAME_USER \n PASS: $PGS_NAME_PASS \033[0m\n"

	PGS_PATH_CONF=$(su - postgres -c 'psql -d postgres -c "SHOW config_file;"' | grep -E -o '|\/.*\/|' )

	if [[ -f $PGS_PATH_CONF"pg_hba.conf" ]]; then
		echo "local    all            $PGS_NAME_USER                            md5"  >>  $PGS_PATH_CONF"pg_hba.conf"
	fi
fi


systemctl restart postgresql




# ### переходим в пользователя postgres
# su postgres

# ### Заходим консоль postgres
# psql

# ### Создаем базу ($PGS_NAME_DB) и нашего пользователя ($PGS_NAME_USER) с паролем ($PGS_NAME_PASS)
# CREATE DATABASE $PGS_NAME_DB;
# CREATE USER $PGS_NAME_USER WITH ENCRYPTED PASSWORD '$PGS_NAME_PASS';
# GRANT ALL PRIVILEGES ON DATABASE $PGS_NAME_DB TO $PGS_NAME_USER;

# ### Смотрим папку где конфиги postgres (в Ubuntu 22 получим /etc/postgresql/15/main/, в 20 /var/lib/pgsql/14/data/)
# SHOW config_file;

# ### Выходим с консоли postgres
# \q

# ### Выходим из пользователя postgres
# exit

# ### В случае ошибок - идум в логи



#PGS_NAME_DB="pegasus"
#PGS_NAME_USER="pegasus_user"
#PGS_NAME_PASS="pegasus_pass"


#GRANT ALL PRIVILEGES ON DATABASE "pegasus" to pegasus_user;

#\c pegasus

#GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "pegasus_user";


#GRANT ALL ON schema public TO pegasus_user;



#  ==============================================================o


# входим в систему под суперпользователем
sudo -i -u postgres

# запускаем управление через консоль
psql

# подключаем к нужной БД, иначе все команды будут применяться к БД по умолчанию супер-пользователя
\с pegasus




CREATE ROLE "laraRole" NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT "laraRole" TO lara;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO GROUP "laraRole";


GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO lara;


ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO lara;


# разрешаем запускать автоинкременты
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO lara;

# передаем права пользователю, можно запустить только из под суперпользователея или владельца
ALTER DATABASE pegasus OWNER TO lara;

ALTER DATABASE pegasus OWNER TO pegasus;


# посмотреть БД
\l

# посмотреть таблицы
\dt

# Постмотреть автоинкременты
\ds



# Поскольку вы меняете владельца для всех таблиц, вам, вероятно, также нужны представления и последовательности. Вот что я сделал:

# Таблицы:
for tbl in 'psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" YOUR_DB' ; do  psql -c "alter table \"$tbl\" owner to NEW_OWNER" YOUR_DB ; done

for tbl in 'psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" postgres' ; do  psql -c "alter table \"$tbl\" owner to lara" postgres ; done


SELECT 'ALTER TABLE '|| schemaname || '.' || tablename ||' OWNER TO lara;'
FROM pg_tables WHERE NOT schemaname IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename;


-----


# Последовательности:
for tbl in 'psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" YOUR_DB' ; do  psql -c "alter sequence \"$tbl\" owner to NEW_OWNER" YOUR_DB ; done

# Просмотры:
for tbl in 'psql -qAt -c "select table_name from information_schema.views where table_schema = 'public';" YOUR_DB' ; do  psql -c "alter view \"$tbl\" owner to NEW_OWNER" YOUR_DB ; done



#========      ДАМП    ===========#

pg_dump -O pegasus | gzip > pegasus_db.gz


gunzip -c pegasus_db.gz | psql pegasus



# Генератор SQL для смены OWner

=========================================

Таблицы

SELECT 'ALTER TABLE '|| schemaname || '.' || tablename ||' OWNER TO my_new_owner;'
FROM pg_tables WHERE NOT schemaname IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename;




SELECT 'ALTER TABLE '|| schemaname || '.' || tablename ||' OWNER TO pegasus;'
FROM pg_tables WHERE NOT schemaname IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename;



последовательности

SELECT 'ALTER SEQUENCE '|| sequence_schema || '.' || sequence_name ||' OWNER TO my_new_owner;'
FROM information_schema.sequences WHERE NOT sequence_schema IN ('pg_catalog', 'information_schema')
ORDER BY sequence_schema, sequence_name;




SELECT 'ALTER SEQUENCE '|| sequence_schema || '.' || sequence_name ||' OWNER TO lara;'
FROM information_schema.sequences WHERE NOT sequence_schema IN ('pg_catalog', 'information_schema')
ORDER BY sequence_schema, sequence_name;



Просмотры

SELECT 'ALTER VIEW '|| table_schema || '.' || table_name ||' OWNER TO my_new_owner;'
FROM information_schema.views WHERE NOT table_schema IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;
Материализованные представления





REASSIGN OWNED BY postgres TO laraRole




DROP DATABASE pegasus;

CREATE DATABASE pegasus;

sudo -i -u postgres


grant all privileges on database pegasus to pegasus;



ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO readonly;
GRANT USAGE ON SCHEMA public to readonly; 
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;



