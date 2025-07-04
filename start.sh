#!/bin/bash
set -e
> install.log
trap 'echo -e "\n\033[0;31m❌ Install failed. Check install.log\033[0m\n"; tail -n 50 install.log' ERR

SSH_PORT=

DOMAIN=
PUBLIC_PATH=""
SWAP=2048

PHP_V=8.1

MYS_NAME_DB=
MYS_NAME_USER=
MYS_PASS_USER=


PGS_NAME_DB=
PGS_NAME_USER=
PGS_NAME_PASS=



export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive
## Questions that you really, really need to see (or else). ##
export DEBIAN_PRIORITY=critical

# Ходим по файлам кроме списка и выполняем их
EXCLUDE_LIST=("." ".." "start.sh")
for file in $(ls -a) ; do 
	if ! [[ ${EXCLUDE_LIST[@]} =~ $file ]]; then
		. "$file"; 
	fi
done


systemctl daemon-reload

echo -en "\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall site complete \033[0m\n"
echo -en "\033[1;32m============================ \033[0m\n"
