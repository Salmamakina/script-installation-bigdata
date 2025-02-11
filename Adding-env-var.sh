#!/bin/bash

role=$1
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
     echo "Writing Environment variables to .bashrc"
     echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' | sudo tee -a /etc/profile > /dev/null
     echo 'export HADOOP_HOME=/opt/hadoop' | sudo tee -a /etc/profile > /dev/null
     echo 'export HADOOP_INSTALL=$HADOOP_HOME' | sudo tee -a /etc/profile > /dev/null
     echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' | sudo tee -a /etc/profile > /dev/null
     echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' | sudo tee -a /etc/profile > /dev/null
     echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' | sudo tee -a /etc/profile > /dev/null
     echo 'export HADOOP_YARN_HOME=$HADOOP_HOME' | sudo tee -a /etc/profile > /dev/null
     echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' | sudo tee -a /etc/profile > /dev/null
     echo 'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin' | sudo tee -a /etc/profile > /dev/null
     echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"' | sudo tee -a /etc/profile > /dev/null
     echo 'export SPARK_HOME=/opt/spark' | sudo tee -a /etc/profile > /dev/null
     echo 'export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop' | sudo tee -a /etc/profile > /dev/null
fi

# Refreshing enviroment for master
if [ "$role" = "master" ]; then
    source ~/.bashrc
    source /etc/profile
fi