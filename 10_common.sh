#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi
if ! [[ $SSH_PORT ]] ; then SSH_PORT=8675 ; fi
if ! [[ $DOMAIN ]] ; then DOMAIN="Server" ; fi


#=======================================================#
#=====================    Общее   ======================#
#=======================================================#

echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall $DOMAIN         \033[0m\n\n"

hostnamectl set-hostname $DOMAIN

NEEDRESTART_MODE=a
DEBIAN_FRONTEND=noninteractive 

echo -en "\033[1;33m Update Ubuntu \033[0m\n" 
apt-get update 		> $LOG_FILE 2>&1
apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >> $LOG_FILE 2>&1

apt-get install -y software-properties-common  	> $LOG_FILE 2>&1
add-apt-repository -y ppa:ondrej/php		> $LOG_FILE 2>&1

apt-get update		> $LOG_FILE 2>&1

echo -en "\033[1;33m Install unzip \033[0m\n" 
apt-get install -y unzip 	> $LOG_FILE 2>&1

echo -en "\033[1;33m Install htop \033[0m\n" 
apt-get install -y htop  	> $LOG_FILE 2>&1

echo -en "\033[1;33m Install curl \033[0m\n" 
apt-get install -y curl  	> $LOG_FILE 2>&1

echo -en "\033[1;33m Install git \033[0m\n" 
apt-get install -y git 		> $LOG_FILE 2>&1



#====================  Config SSH  =====================#

echo -en "\033[1;33m Config SSH \033[0m\n" 

sed -i '/Port /s/.*/Port '$SSH_PORT'/' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication yes/s/.*/PasswordAuthentication no/' /etc/ssh/sshd_config

systemctl restart ssh

echo -en "\033[1;33m SSH SET\033[0m"
echo -en "\033[1;32m $SSH_PORT\033[0m\n"

#=======================================================#
#====================    ADD SWAP  =====================#
#=======================================================#

echo -en "\033[1;33m Setting SWAP  \033[0m\n"

if [[ $SWAP ]] ; then

    # del old swap
    if [ -f /swapfile ]; then
        # stop swap
        swapoff /swapfile
        rm /swapfile
    fi

    # create swap
    #fallocate -l 4G /swapfile
    dd if=/dev/zero of=/swapfile bs=$SWAP count=1048576

    # only root
    chmod 600 /swapfile

    # разметим swap
    mkswap /swapfile
    # ON swap
    swapon /swapfile

    # add forever start
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

    # желание переносить в swap
    sysctl vm.swappiness=30
    sysctl -w vm.swappiness=30

    # желание чистить swap
    sysctl vm.vfs_cache_pressure=30
    sysctl -w vm.vfs_cache_pressure=30

fi

echo -en "\n\033[1;32m============================ \033[0m\n\n"
