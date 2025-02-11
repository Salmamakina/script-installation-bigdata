#!/bin/bash

set -x
# basic update
echo " Basic updates "
sudo apt-get update -y
sudo apt-get upgrade -y

# Install dir
DIR=/opt
REPO_GITHUB=/tmp/repo_installation
MASTER_IP_ADDRESS=$1
role=$2
FILE_PATH="$REPO_GITHUB/ip_addresses.txt"

# Downloading Binaries
if ! [ -f ./tar/hadoop-3.4.0.tar.gz ]; then
  echo "Hadoop Binary isn't found downloading ... "
  wget -P ./tar https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
fi

if ! [ -f ./tar/spark-3.4.3-bin-hadoop3.tgz ]; then
  echo "Spark Binary isn't found downloading ... "
  wget -P ./tar https://dlcdn.apache.org/spark/spark-3.5.4/spark-3.5.4-bin-hadoop3.tgz

fi

# Enregistrer les adresses IP dans un fichier texte
echo "MASTER_IP_ADDRESS=$MASTER_IP_ADDRESS" > $FILE_PATH
echo "role=$role" >> $FILE_PATH
# Replacing templates Ip adresses with given Ip adresses
sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" $REPO_GITHUB/config-$role/core-site.xml
sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" $REPO_GITHUB/config-$role/yarn-site.xml


# Untaring Hadoop and spark Binaries
echo  " Untaring hadoop to kepler folder ... "
tar -zxf ./tar/hadoop-3.4.0.tar.gz --directory $DIR
echo  " Untaring spark to kepler folder ... "
tar -zxf ./tar/spark-3.5.4-bin-hadoop3.tgz --directory $DIR
echo " Renaming Folders ... "
mv $DIR/hadoop* $DIR/hadoop
mv $DIR/spark* $DIR/spark


# Removing default hdfs and spark on yarn config
echo " Removing Default config files ... "
rm $DIR/hadoop/etc/hadoop/hdfs-site.xml
rm $DIR/hadoop/etc/hadoop/yarn-site.xml
rm $DIR/hadoop/etc/hadoop/core-site.xml
rm $DIR/hadoop/etc/hadoop/hadoop-env.sh

# Copying updated ip adress
echo " Copying new config files ... "
sudo cp $REPO_GITHUB/config-$role/yarn-site.xml $DIR/hadoop/etc/hadoop/
sudo cp $REPO_GITHUB/config-$role/hdfs-site.xml $DIR/hadoop/etc/hadoop/
sudo cp $REPO_GITHUB/config-$role/core-site.xml $DIR/hadoop/etc/hadoop/
sudo cp $REPO_GITHUB/config-$role/hadoop-env.sh $DIR/hadoop/etc/hadoop/

# Adding systemd services
cp $REPO_GITHUB/$role-systemd/hadoop.service /etc/systemd/system/
cp $REPO_GITHUB/$role-systemd/yarn.service /etc/systemd/system/

# Formatting the namenode
if [ "$role" = "master" ]; then
    hdfs namenode -format
fi

# Enabling services 
echo "Enabling service files ... "
systemctl daemon-reload
systemctl enable hadoop.service
systemctl enable yarn.service

# Starting the services
echo "Starting services ... "
systemctl start hadoop.service
systemctl start yarn.service

if [ "$role" = "master" ]; then
     sudo apt-get install -y docker.io
     sudo systemctl start docker
     sudo systemctl enable docker
     sudo usermod -aG docker $(whoami)
     newgrp docker
     sudo systemctl restart docker
     sudo apt-get install -y python3-pip
     sudo pip3 install docker-compose
     sudo chmod +x /usr/local/bin/docker-compose
fi

if "$role" = "master"; then
    # Run Docker-compose
    sudo docker-compose -f $REPO_GITHUB/docker-compose.yml up -d
fi