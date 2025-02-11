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
  wget -P ./tar https://dlcdn.apache.org/spark/spark-3.4.3/spark-3.4.3-bin-hadoop3.tgz
fi

# Enregistrer les adresses IP dans un fichier texte
echo "MASTER_IP_ADDRESS=$MASTER_IP_ADDRESS" > $FILE_PATH
echo "role=$role" > $FILE_PATH
# Replacing templates Ip adresses with given Ip adresses
sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" $REPO_GITHUB/config-$role/core-site.xml
sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" $REPO_GITHUB/config-$role/yarn-site.xml


# Untaring Hadoop and spark Binaries
echo  " Untaring hadoop to kepler folder ... "
tar -zxf ./tar/hadoop-3.4.0.tar.gz --directory $DIR
echo  " Untaring spark to kepler folder ... "
tar -zxf ./tar/spark-3.4.3-bin-hadoop3.tgz --directory $DIR
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
cp $REPO_GITHUB/config-$role/yarn-site.xml $DIR/hadoop/etc/hadoop/
cp $REPO_GITHUB/config-$role/hdfs-site.xml $DIR/hadoop/etc/hadoop/
cp $REPO_GITHUB/config-$role/core-site.xml $DIR/hadoop/etc/hadoop/
cp $REPO_GITHUB/config-$role/hadoop-env.sh $DIR/hadoop/etc/hadoop/


# Adding enviroment variables
echo " Writing Enviroment variables to .bashrc ... "
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
echo 'export HADOOP_HOME=/opt/hadoop' >> ~/.bashrc
echo 'export HADOOP_INSTALL=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_YARN_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin' >> ~/.bashrc
echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"' >> ~/.bashrc
echo 'export SPARK_HOME=/opt/spark' >> ~/.bashrc
echo 'export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop' >> ~/.bashrc


# Adding Master profile environment variables
if [ "$role" = "master" ]; then
    echo " Writing Enviroment variables to .bashrc "
    echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /etc/profile
    echo 'export HADOOP_HOME=/opt/hadoop' >> /etc/profile
    echo 'export HADOOP_INSTALL=$HADOOP_HOME' >> /etc/profile
    echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> /etc/profile
    echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> /etc/profile
    echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> /etc/profile
    echo 'export HADOOP_YARN_HOME=$HADOOP_HOME' >> /etc/profile
    echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> /etc/profile
    echo 'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin' >> /etc/profile
    echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"' >> /etc/profile
    echo 'export SPARK_HOME=/opt/spark' >> /etc/profile
    echo 'export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop' >> /etc/profile
    echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"' >> /etc/profile
    echo 'export SPARK_HOME=/opt/spark' >> /etc/profile
fi

# Adding systemd services
cp $REPO_GITHUB/$role-systemd/hadoop.service /etc/systemd/system/
cp $REPO_GITHUB/$role-systemd/yarn.service /etc/systemd/system/

# Refreshing enviroment for master
if [ "$role" = "master" ]; then
    source ~/.bashrc
    source /etc/profile
fi

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
     sudo systemctl restart docker
     sudo apt-get install -y python3-pip
     sudo pip3 install docker-compose
     sudo chmod +x /usr/local/bin/docker-compose
fi

if "$role" = "master"; then
    # Run Docker-compose
    sudo docker-compose -f $REPO_GITHUB/docker-compose.yml up -d
fi