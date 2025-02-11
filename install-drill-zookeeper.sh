#!/bin/bash

# Variables
DIR=/opt
REPO_GITHUB=/tmp/repo_installation
role=$1


if ! [ -f ./tar/apache-zookeeper-3.9.2-bin.tar.gz ]; then
  echo "zookeeper Binary isn't found downloading ... "
  wget -P ./tar https://dlcdn.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3.tar.gz
fi

if ! [ -f ./tar/apache-drill-1.21.1.tar.gz ]; then
  echo "Drill Binary isn't found downloading ... "
  wget -P ./tar https://dlcdn.apache.org/drill/1.21.2/apache-drill-1.21.2.tar.gz
fi

echo  " Untaring zookeeper to kepler folder ... "
tar -zxf ./tar/apache-zookeeper-3.9.3.tar.gz --directory $DIR
echo  " Untaring drill to kepler folder ... "
tar -zxf ./tar/apache-drill-1.21.2.tar.gz --directory $DIR
mv $DIR/apache-zookeeper* $DIR/zookeeper
mv $DIR/apache-drill* $DIR/drill

sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" $REPO_GITHUB/config-drill/drill-override.conf
sudo rm /opt/drill/conf/drill-override.conf
sudo cp $REPO_GITHUB/config-drill/drill-override.conf /opt/drill/conf/
sudo cp $REPO_GITHUB/config-drill/zoo.cfg /opt/zookeeper/conf/ 
# apt install -y net-tools
# apt install -y netcat 

sudo cp $REPO_GITHUB/$role-systemd/drill.service /etc/systemd/system/
sudo cp $REPO_GITHUB/$role-systemd/zookeeper.service /etc/systemd/system/

# Enabling services 
echo "Enabling service files ... "
systemctl daemon-reload
systemctl enable drill.service
systemctl enable zookeeper.service
systemctl start drill.service
systemctl start zookeeper.service