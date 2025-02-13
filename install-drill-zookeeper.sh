#!/bin/bash

# Variables
DIR=/opt
REPO_GITHUB=/tmp/repo_installation
MASTER_IP_ADDRESS=$1
WORKER_IP_ADDRESS=$2
role=$3

# if ! [ -f ./tar/apache-zookeeper-3.9.2-bin.tar.gz ]; then
#   echo "zookeeper Binary isn't found downloading ... "
#   wget -P ./tar https://dlcdn.apache.org/zookeeper/zookeeper-3.9.3/apache-zookeeper-3.9.3-bin.tar.gz
# fi

# if ! [ -f ./tar/apache-drill-1.21.1.tar.gz ]; then
#   echo "Drill Binary isn't found downloading ... "
#   wget -P ./tar https://dlcdn.apache.org/drill/1.21.2/apache-drill-1.21.2.tar.gz
# fi

# echo  " Untaring zookeeper to kepler folder ... "
# tar -zxf ./tar/apache-zookeeper-3.9.3-bin.tar.gz --directory $DIR
# echo  " Untaring drill to kepler folder ... "
# tar -zxf ./tar/apache-drill-1.21.2.tar.gz --directory $DIR
# mv $DIR/apache-zookeeper* $DIR/zookeeper
# mv $DIR/apache-drill* $DIR/drill

# # configuring the addresses in drill 
# sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" $REPO_GITHUB/config-drill/drill-override.conf
# sed -i "s|\${WORKER_IP_ADDRESS}|$WORKER_IP_ADDRESS|g" $REPO_GITHUB/config-drill/drill-override.conf

# sudo rm /opt/drill/conf/drill-override.conf
# sudo cp $REPO_GITHUB/config-drill/drill-override.conf /opt/drill/conf/


# # Générer le fichier zoo.cfg avec les valeurs réelles
# cat > /opt/zookeeper/conf/zoo.cfg <<EOL
# tickTime=2000
# dataDir=/var/lib/zookeeper
# dataLogDir=/var/lib/zookeeper
# clientPort=2181
# initLimit=5
# syncLimit=2
# server.0=$MASTER_IP_ADDRESS:2888:3888
# server.1=$WORKER_IP_ADDRESS:2888:3888
# EOL

# # Define the file myid in the zookeeper
# if [ "$role" == "master" ]; then
#     MYID=0
# else
#     MYID=1
# fi

# # Créer le répertoire s'il n'existe pas
# sudo mkdir -p /var/lib/zookeeper
# echo "$MYID" | sudo tee /var/lib/zookeeper/myid

apt install -y net-tools
apt install -y netcat 

sudo cp $REPO_GITHUB/$role-systemd/drill.service /etc/systemd/system/
sudo cp $REPO_GITHUB/$role-systemd/zookeeper.service /etc/systemd/system/

# Enabling services 
echo "Enabling service files ... "
systemctl daemon-reload
systemctl enable drill.service
systemctl enable zookeeper.service
systemctl start drill.service
systemctl start zookeeper.service