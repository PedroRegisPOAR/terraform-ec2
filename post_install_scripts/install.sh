#!/bin/bash

#sudo apt install make curl -y
#curl -fsSL https://get.docker.com -o get-docker.sh
#sudo sh get-docker.sh
#sudo curl -L "https://github.com/docker/compose/releases/download/1.26.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#sudo chmod +x /usr/local/bin/docker-compose
#rm get-docker.sh

sudo apt-get update
sudo apt-get install curl -y


#file_string=$(echo -e "$(cat <<"EOF"
#echo test
#EOF
#)")
#
#echo "$file_string" > /home/ubuntu/Makefile
#
#file_string=$(echo -e "$(cat <<"EOF"
##!/bin/bash
#
#EOF
#)")
#echo "$file_string" > /home/ubuntu/daily_cron.sh
#chmod +x /home/ubuntu/daily_cron.sh

