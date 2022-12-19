#!/bin/bash
DESTINATION=$1
PORT=$2
CHAT=$3
#install docker
sudo apt update && apt upgrade
sudo apt install -y docker docker-compose
sudo usermod -aG docker ${USER}
newgrp docker
# init docker swarm
sudo docker swarm init --advertise-addr $HOST_IP
# clone Odoo directory
git clone --depth=1 https://github.com/thaichikma/docker-odoo -b 14.0 $DESTINATION
rm -rf $DESTINATION/.git
# set permission
mkdir -p $DESTINATION/postgresql
sudo chmod -R 777 $DESTINATION
# config
if grep -qF "fs.inotify.max_user_watches" /etc/sysctl.conf; then echo $(grep -F "fs.inotify.max_user_watches" /etc/sysctl.conf); else echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf; fi
sudo sysctl -p
sed -i 's/10012/'$PORT'/g' $DESTINATION/docker-compose.yml
sed -i 's/20012/'$CHAT'/g' $DESTINATION/docker-compose.yml
# run Odoo
docker-compose -f $DESTINATION/docker-compose.yml up -d

echo 'Started Odoo @ http://localhost:'$PORT' | Live chat port: '$CHAT
