#!/bin/bash

# basic update
echo " Basic updates "
sudo apt-get update -y
sudo apt-get upgrade -y

# Install dir
DIR=/opt
USER=ubuntu

# # Downloading Binaries
# if ! [ -f ./tar/hadoop-3.4.0.tar.gz ]; then
#   echo "Hadoop Binary isn't found downloading ... "
#   wget -P ./tar https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
# fi

# if ! [ -f ./tar/spark-3.4.3-bin-hadoop3.tgz ]; then
#   echo "Spark Binary isn't found downloading ... "
#   wget -P ./tar https://dlcdn.apache.org/spark/spark-3.4.3/spark-3.4.3-bin-hadoop3.tgz
# fi

# if ! [ -f ./tar/apache-zookeeper-3.9.2-bin.tar.gz ]; then
#   echo "zookeeper Binary isn't found downloading ... "
#   wget -P ./tar https://dlcdn.apache.org/zookeeper/zookeeper-3.9.2/apache-zookeeper-3.9.2-bin.tar.gz
# fi

# if ! [ -f ./tar/apache-drill-1.21.1.tar.gz ]; then
#   echo "Drill Binary isn't found downloading ... "
#   wget -P ./tar https://dlcdn.apache.org/drill/1.21.1/apache-drill-1.21.1.tar.gz
# fi

MASTER_IP_ADDRESS=10.1.0.3
# Submit valid IP
VERIF=N
until [ "$VERIF" = "Y" ];
do
    echo "                                                              ";
    echo "The ip is $MASTER_IP_ADDRESS do you want to proceed ? (Y/[N])";
    echo "                                                              ";
    read -p "Proceed ?: " VERIF;
done
echo " Writing Enviroment variables to .bashrc ... "
echo 'export MASTER_IP_ADDRESS='"$MASTER_IP_ADDRESS" >> ~/.bashrc

# # Replacing templates Ip adresses with given Ip adresses
# sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" ./config-master/core-site.xml
# sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" ./config-master/yarn-site.xml

# # installing openjdk
# echo " Installing openjdk "
# apt install -y openjdk-11-jdk
# apt install ca-certificates-java
# apt install -y docker-compose
# echo " JDK install done "

# # Untaring Hadoop and spark Binaries
# echo  " Untaring hadoop to kepler folder ... "
# tar -zxf ./tar/hadoop-3.4.0.tar.gz --directory $DIR
# echo  " Untaring spark to kepler folder ... "
# tar -zxf ./tar/spark-3.4.3-bin-hadoop3.tgz --directory $DIR
# echo " Renaming Folders ... "
# mv $DIR/hadoop* $DIR/hadoop
# mv $DIR/spark* $DIR/spark

# echo  " Untaring zookeeper to kepler folder ... "
# tar -zxf ./tar/apache-zookeeper-3.9.2-bin.tar.gz --directory $DIR
# echo  " Untaring drill to kepler folder ... "
# tar -zxf ./tar/apache-drill-1.21.1.tar.gz --directory $DIR
# mv $DIR/apache-zookeeper* $DIR/zookeeper
# mv $DIR/apache-drill* $DIR/drill

# # Removing default hdfs and spark on yarn config
# echo " Removing Default config files ... "
# rm $DIR/hadoop/etc/hadoop/hdfs-site.xml
# rm $DIR/hadoop/etc/hadoop/yarn-site.xml
# rm $DIR/hadoop/etc/hadoop/core-site.xml
# rm $DIR/hadoop/etc/hadoop/hadoop-env.sh