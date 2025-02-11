#!/bin/bash

role=$1
BASHRC="$HOME/.bashrc"
PROFILE="/etc/profile"

# Fonction pour ajouter une variable d'environnement si elle n'existe pas encore
add_env_variable() {
    local file=$1
    local var_name=$2
    local var_value=$3

    # Vérifier si la variable existe déjà dans le fichier
    if ! grep -q "^export $var_name=" "$file"; then
        echo "export $var_name=$var_value" | sudo tee -a "$file" > /dev/null
    else
        echo "$var_name already exists in $file, skipping..."
    fi
}

echo "Updating environment variables..."

# Ajouter les variables à .bashrc
add_env_variable "$BASHRC" "JAVA_HOME" "/usr/lib/jvm/java-11-openjdk-amd64"
add_env_variable "$BASHRC" "HADOOP_HOME" "/opt/hadoop"
add_env_variable "$BASHRC" "HADOOP_INSTALL" "\$HADOOP_HOME"
add_env_variable "$BASHRC" "HADOOP_MAPRED_HOME" "\$HADOOP_HOME"
add_env_variable "$BASHRC" "HADOOP_COMMON_HOME" "\$HADOOP_HOME"
add_env_variable "$BASHRC" "HADOOP_HDFS_HOME" "\$HADOOP_HOME"
add_env_variable "$BASHRC" "HADOOP_YARN_HOME" "\$HADOOP_HOME"
add_env_variable "$BASHRC" "HADOOP_COMMON_LIB_NATIVE_DIR" "\$HADOOP_HOME/lib/native"
add_env_variable "$BASHRC" "PATH" "\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin"
add_env_variable "$BASHRC" "HADOOP_OPTS" "\"-Djava.library.path=\$HADOOP_HOME/lib/native\""
add_env_variable "$BASHRC" "SPARK_HOME" "/opt/spark"
add_env_variable "$BASHRC" "HADOOP_CONF_DIR" "/opt/hadoop/etc/hadoop"

# Ajouter les variables à /etc/profile si l'hôte est "master"
if [ "$role" = "master" ]; then
    echo "Updating environment variables for master in /etc/profile..."
    add_env_variable "$PROFILE" "JAVA_HOME" "/usr/lib/jvm/java-11-openjdk-amd64"
    add_env_variable "$PROFILE" "HADOOP_HOME" "/opt/hadoop"
    add_env_variable "$PROFILE" "HADOOP_INSTALL" "\$HADOOP_HOME"
    add_env_variable "$PROFILE" "HADOOP_MAPRED_HOME" "\$HADOOP_HOME"
    add_env_variable "$PROFILE" "HADOOP_COMMON_HOME" "\$HADOOP_HOME"
    add_env_variable "$PROFILE" "HADOOP_HDFS_HOME" "\$HADOOP_HOME"
    add_env_variable "$PROFILE" "HADOOP_YARN_HOME" "\$HADOOP_HOME"
    add_env_variable "$PROFILE" "HADOOP_COMMON_LIB_NATIVE_DIR" "\$HADOOP_HOME/lib/native"
    add_env_variable "$PROFILE" "PATH" "\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin"
    add_env_variable "$PROFILE" "HADOOP_OPTS" "\"-Djava.library.path=\$HADOOP_HOME/lib/native\""
    add_env_variable "$PROFILE" "SPARK_HOME" "/opt/spark"
    add_env_variable "$PROFILE" "HADOOP_CONF_DIR" "/opt/hadoop/etc/hadoop"
fi

# Recharger les variables d’environnement
source "$BASHRC"
if [ "$role" = "master" ]; then
    source "$PROFILE"
fi

echo "Environment variables updated successfully!"
