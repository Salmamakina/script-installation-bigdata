#!/bin/bash

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

if ! [ -f ./tar/apache-zookeeper-3.9.2-bin.tar.gz ]; then
  echo "zookeeper Binary isn't found downloading ... "
  wget -P ./tar https://dlcdn.apache.org/zookeeper/zookeeper-3.9.2/apache-zookeeper-3.9.2-bin.tar.gz
fi

if ! [ -f ./tar/apache-drill-1.21.1.tar.gz ]; then
  echo "Drill Binary isn't found downloading ... "
  wget -P ./tar https://dlcdn.apache.org/drill/1.21.1/apache-drill-1.21.1.tar.gz
fi
# Machine Role
echo "                                                                                             ";
echo "███╗   ███╗ █████╗  ██████╗██╗  ██╗██╗███╗   ██╗███████╗    ██████╗  ██████╗ ██╗     ███████╗";
echo "████╗ ████║██╔══██╗██╔════╝██║  ██║██║████╗  ██║██╔════╝    ██╔══██╗██╔═══██╗██║     ██╔════╝";
echo "██╔████╔██║███████║██║     ███████║██║██╔██╗ ██║█████╗      ██████╔╝██║   ██║██║     █████╗  ";
echo "██║╚██╔╝██║██╔══██║██║     ██╔══██║██║██║╚██╗██║██╔══╝      ██╔══██╗██║   ██║██║     ██╔══╝  ";
echo "██║ ╚═╝ ██║██║  ██║╚██████╗██║  ██║██║██║ ╚████║███████╗    ██║  ██║╚██████╔╝███████╗███████╗";
echo "╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝";
echo "                                                                                             ";
# Récupérer le nom de l'instance à partir de Terraform (en utilisant terraform output)
instance_name=$(terraform output -raw instance_name)

# Vérifier si le nom commence par 'worker' ou non pour déterminer le rôle
if [[ "$instance_name" == worker* ]]; then
  role="worker"
else
  role="master"
fi
echo "Le rôle est : $role"

# Machine IP
echo "                                                                   ";
echo "███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗     ██╗██████╗ ";
echo "████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗    ██║██╔══██╗";
echo "██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝    ██║██████╔╝";
echo "██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗    ██║██╔═══╝ ";
echo "██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║    ██║██║     ";
echo "╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ╚═╝╚═╝     ";
echo "                                                                   ";
MASTER_IP_ADDRESS=$(terraform output -raw master_internal_ip)
WORKER_IP_ADDRESS=$(terraform output -raw worker_ip_internal)

# Submit valid IP
VERIF=N
until [ "$VERIF" = "Y" ];
do
    echo "                                                              ";
    echo "The ip is $MASTER_IP_ADDRESS do you want to proceed ? (Y/[N])";
    echo "                                                              ";
    read -p "Proceed ?: " VERIF;
done
# Replacing templates Ip adresses with given Ip adresses
sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" ./config-$role/core-site.xml
sed -i "s|\${MASTER_IP_ADDRESS}|$MASTER_IP_ADDRESS|g" ./config-$role/yarn-site.xml

# Récupération des paramètres passés par Terraform
MACHINE_TYPE=$(terraform output -raw machine_type)

# Replacing ram and cpu max in yarn
if [ "$role" = "master" ]; then
    echo "                                                          ";
    echo "███╗   ███╗ █████╗ ██╗  ██╗    ██████╗  █████╗ ███╗   ███╗";
    echo "████╗ ████║██╔══██╗╚██╗██╔╝    ██╔══██╗██╔══██╗████╗ ████║";
    echo "██╔████╔██║███████║ ╚███╔╝     ██████╔╝███████║██╔████╔██║";
    echo "██║╚██╔╝██║██╔══██║ ██╔██╗     ██╔══██╗██╔══██║██║╚██╔╝██║";
    echo "██║ ╚═╝ ██║██║  ██║██╔╝ ██╗    ██║  ██║██║  ██║██║ ╚═╝ ██║";
    echo "╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝";
    echo "                                                          ";
    echo "Configuring RAM and CPU for master node..."
    case "$MACHINE_TYPE" in
        "e2-medium") MAX_RAM=4096; MAX_CPU=2 ;;
        "e2-standard-2") MAX_RAM=8192; MAX_CPU=2 ;;
        "e2-highmem-2") MAX_RAM=16384; MAX_CPU=2 ;;
        *) echo "Unknown machine type: $MACHINE_TYPE"; exit 1 ;;
    esac
    echo "Utilisation de $MAX_RAM MB de RAM pour yarn."
    echo "                                                        ";
    echo "███╗   ███╗ █████╗ ██╗  ██╗     ██████╗██████╗ ██╗   ██╗";
    echo "████╗ ████║██╔══██╗╚██╗██╔╝    ██╔════╝██╔══██╗██║   ██║";
    echo "██╔████╔██║███████║ ╚███╔╝     ██║     ██████╔╝██║   ██║";
    echo "██║╚██╔╝██║██╔══██║ ██╔██╗     ██║     ██╔═══╝ ██║   ██║";
    echo "██║ ╚═╝ ██║██║  ██║██╔╝ ██╗    ╚██████╗██║     ╚██████╔╝";
    echo "╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝╚═╝      ╚═════╝ ";
    echo "                                                        ";

    echo "Utilisation de $MAX_CPU CPU pour yarn."
    sed -i "s|\${MAX_RAM}|$MAX_RAM|g" ./config-$role/yarn-site.xml
    sed -i "s|\${MAX_CPU}|$MAX_CPU|g" ./config-$role/yarn-site.xml
fi

# Replacing ram and cpu for worker in yarn
if [ "$role" = "worker" ]; then
    echo "██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗███████╗██████╗     ██████╗  █████╗ ███╗   ███╗";
    echo "██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝██╔════╝██╔══██╗    ██╔══██╗██╔══██╗████╗ ████║";
    echo "██║ █╗ ██║██║   ██║██████╔╝█████╔╝ █████╗  ██████╔╝    ██████╔╝███████║██╔████╔██║";
    echo "██║███╗██║██║   ██║██╔══██╗██╔═██╗ ██╔══╝  ██╔══██╗    ██╔══██╗██╔══██║██║╚██╔╝██║";
    echo "╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗███████╗██║  ██║    ██║  ██║██║  ██║██║ ╚═╝ ██║";
    echo " ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝";
    echo "                                                                                  ";
    echo "Utilisation de $MAX_RAM MB de RAM pour yarn."

    echo "██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗███████╗██████╗      ██████╗██████╗ ██╗   ██╗";
    echo "██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝██╔════╝██╔══██╗    ██╔════╝██╔══██╗██║   ██║";
    echo "██║ █╗ ██║██║   ██║██████╔╝█████╔╝ █████╗  ██████╔╝    ██║     ██████╔╝██║   ██║";
    echo "██║███╗██║██║   ██║██╔══██╗██╔═██╗ ██╔══╝  ██╔══██╗    ██║     ██╔═══╝ ██║   ██║";
    echo "╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗███████╗██║  ██║    ╚██████╗██║     ╚██████╔╝";
    echo " ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝     ╚═════╝╚═╝      ╚═════╝ ";
    echo "                                                                                ";
    echo "Utilisation de $MAX_CPU CPU pour yarn."
    sed -i "s|\${RAM}|$RAM|g" ./config-$role/yarn-site.xml
    sed -i "s|\${CPU}|$CPU|g" ./config-$role/yarn-site.xml
fi
echo "                                                                                  ";
echo "██████╗ ███████╗██████╗ ██╗     ██╗ ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗";
echo "██╔══██╗██╔════╝██╔══██╗██║     ██║██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║";
echo "██████╔╝█████╗  ██████╔╝██║     ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║";
echo "██╔══██╗██╔══╝  ██╔═══╝ ██║     ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║";
echo "██║  ██║███████╗██║     ███████╗██║╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║";
echo "╚═╝  ╚═╝╚══════╝╚═╝     ╚══════╝╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝";
echo "                                                                                  ";
read -p "Replication rate:(1-3): " REPLICATION
sed -i "s|\${REPLICATION}|$REPLICATION|g" ./config-$role/hdfs-site.xml

# installing openjdk
echo " Installing openjdk "
apt install -y openjdk-11-jdk
apt install ca-certificates-java
apt install -y docker-compose
echo " JDK install done "

# Untaring Hadoop and spark Binaries
echo  " Untaring hadoop to kepler folder ... "
tar -zxf ./tar/hadoop-3.4.0.tar.gz --directory $DIR
echo  " Untaring spark to kepler folder ... "
tar -zxf ./tar/spark-3.4.3-bin-hadoop3.tgz --directory $DIR
echo " Renaming Folders ... "
mv $DIR/hadoop* $DIR/hadoop
mv $DIR/spark* $DIR/spark

echo  " Untaring zookeeper to kepler folder ... "
tar -zxf ./tar/apache-zookeeper-3.9.2-bin.tar.gz --directory $DIR
echo  " Untaring drill to kepler folder ... "
tar -zxf ./tar/apache-drill-1.21.1.tar.gz --directory $DIR
mv $DIR/apache-zookeeper* $DIR/zookeeper
mv $DIR/apache-drill* $DIR/drill

# Removing default hdfs and spark on yarn config
echo " Removing Default config files ... "
rm $DIR/hadoop/etc/hadoop/hdfs-site.xml
rm $DIR/hadoop/etc/hadoop/yarn-site.xml
rm $DIR/hadoop/etc/hadoop/core-site.xml
rm $DIR/hadoop/etc/hadoop/hadoop-env.sh

if [ "$role" = "worker" ]; then
  ADDRESS=$WORKER_IP_ADDRESS
else
  ADDRESS=$MASTER_IP_ADDRESS
fi
 # Copying updated ip adress in the worker
echo " Copying new config files ... "
scp ./config-$role/yarn-site.xml $USER@$ADDRESS:$DIR/hadoop/etc/hadoop/
scp ./config-$role/hdfs-site.xml $USER@$ADDRESS:$DIR/hadoop/etc/hadoop/
scp ./config-$role/core-site.xml $USER@$ADDRESS:$DIR/hadoop/etc/hadoop/
scp ./config-$role/hadoop-env.sh $USER@$ADDRESS:$DIR/hadoop/etc/hadoop/
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
fi
# Refreshing enviroment for master
if [ "$role" = "master" ]; then
    source ~/.bashrc
    source /etc/profile
fi

# Formatting the namenode
if [ "$role" = "master" ]; then
    hdfs namenode -format
fi

# Adding systemd services for the master
scp ./$role-systemd/hadoop.service $USER@$ADDRESS:/etc/systemd/system/

# Recharger systemd pour détecter le nouveau service
systemctl daemon-reload

# Activer et démarrer Hadoop
systemctl enable hadoop.service
systemctl start hadoop.service

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

if [ "$role" = "master" ] && [ -f "/home/$USER/docker-compose.yml" ]; then
    cd /home/$USER
    sudo docker-compose -f /home/$USER/docker-compose.yml up -d
fi