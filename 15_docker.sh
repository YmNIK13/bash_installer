#!/bin/bash

if ! [[ $LOG_FILE ]] ; then LOG_FILE="install.log" ; fi


echo -en "\n\033[1;32m============================ \033[0m\n"
echo -en "\033[1;32mInstall Docker   \033[0m\n\n"


apt update 										> $LOG_FILE 2>&1

apt install -y ca-certificates curl gnupg		> $LOG_FILE 2>&1

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update										> $LOG_FILE 2>&1

apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin		> $LOG_FILE 2>&1

