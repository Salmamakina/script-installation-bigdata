#!/bin/bash
set -x
# basic update
echo " Basic updates "
sudo apt-get update -y
sudo apt-get upgrade -y

# Install dir
DIR=/opt
USER=ubuntu

# Downloading Binaries
if ! [ -f ./tar/hadoop-3.4.0.tar.gz ]; then
  echo "Hadoop Binary isn't found downloading ... "
  wget -P ./tar https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
fi

if ! [ -f ./tar/spark-3.4.3-bin-hadoop3.tgz ]; then
  echo "Spark Binary isn't found downloading ... "
  wget -P ./tar https://dlcdn.apache.org/spark/spark-3.4.3/spark-3.4.3-bin-hadoop3.tgz
fi

# if ! [ -f ./tar/apache-zookeeper-3.9.2-bin.tar.gz ]; then
#   echo "zookeeper Binary isn't found downloading ... "
#   wget -P ./tar https://dlcdn.apache.org/zookeeper/zookeeper-3.9.2/apache-zookeeper-3.9.2-bin.tar.gz
# fi

# if ! [ -f ./tar/apache-drill-1.21.1.tar.gz ]; then
#   echo "Drill Binary isn't found downloading ... "
#   wget -P ./tar https://dlcdn.apache.org/drill/1.21.1/apache-drill-1.21.1.tar.gz
# fi

MASTER_IP_ADDRESS=$1
FILE_PATH="/tmp/repo_installation/ip_addresses.txt"

# Enregistrer les adresses IP dans un fichier texte
echo "MASTER_IP_ADDRESS=$MASTER_IP_ADDRESS" > $FILE_PATH

echo "Adresses IP enregistrées dans $FILE_PATH."

# Replacing templates Ip adresses with given Ip adresses
sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" ./config-master/core-site.xml
sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" ./config-master/yarn-site.xml

# installing openjdk
echo " Installing openjdk "
apt install -y openjdk-11-jdk
apt install ca-certificates-java
echo " JDK install done "

# Untaring Hadoop and spark Binaries
echo  " Untaring hadoop to kepler folder ... "
tar -zxf ./tar/hadoop-3.4.0.tar.gz --directory $DIR
echo  " Untaring spark to kepler folder ... "
tar -zxf ./tar/spark-3.4.3-bin-hadoop3.tgz --directory $DIR
echo " Renaming Folders ... "
mv $DIR/hadoop* $DIR/hadoop
mv $DIR/spark* $DIR/spark

# echo  " Untaring zookeeper to kepler folder ... "
# tar -zxf ./tar/apache-zookeeper-3.9.2-bin.tar.gz --directory $DIR
# echo  " Untaring drill to kepler folder ... "
# tar -zxf ./tar/apache-drill-1.21.1.tar.gz --directory $DIR
# mv $DIR/apache-zookeeper* $DIR/zookeeper
# mv $DIR/apache-drill* $DIR/drill

# Removing default hdfs and spark on yarn config
echo " Removing Default config files ... "
rm $DIR/hadoop/etc/hadoop/hdfs-site.xml
rm $DIR/hadoop/etc/hadoop/yarn-site.xml
rm $DIR/hadoop/etc/hadoop/core-site.xml
rm $DIR/hadoop/etc/hadoop/hadoop-env.sh

# Copying updated ip adress
echo " Copying new config files ... "
cp ./config-master/yarn-site.xml $DIR/hadoop/etc/hadoop/
cp ./config-master/hdfs-site.xml $DIR/hadoop/etc/hadoop/
cp ./config-master/core-site.xml $DIR/hadoop/etc/hadoop/
cp ./config-master/hadoop-env.sh $DIR/hadoop/etc/hadoop/


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


echo " Writing Enviroment variables to .bashrc "
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /etc/profile
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

# Adding systemd services
cp ./master-systemd/hadoop.service /etc/systemd/system/
# cp ./master-systemd/yarn.service /etc/systemd/system/
# cp ./master-systemd/drill.service /etc/systemd/system/
# cp ./master-systemd/zookeeper.service /etc/systemd/system/


source ~/.bashrc
source /etc/profile

hdfs namenode -format

# Enabling services 
echo "Enabling service files ... "
systemctl daemon-reload
systemctl enable hadoop.service
# systemctl enable yarn.service
# systemctl enable drill.service
# systemctl enable zookeeper.service

# Starting the services
echo "Starting services ... "
systemctl start hadoop.service
# systemctl start yarn.service

sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)
sudo systemctl restart docker
sudo apt-get install -y python3-pip
sudo pip3 install docker-compose
sudo chmod +x /usr/local/bin/docker-compose

if -f "/home/$USER/docker-compose.yml" ; then
    cd /home/$USER
    sudo docker-compose -f /home/$USER/docker-compose.yml up -d
fi