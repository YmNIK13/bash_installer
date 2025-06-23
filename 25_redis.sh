#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi


#=======================================================#
echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall redis  \033[0m\n"
echo -en "\033[1;32m============================ \033[0m\n"

apt-get install -y redis-server > $LOG_FILE 2>&1

