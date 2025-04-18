pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'sonarqube-scanner'
        TERRAFORM_HOME = '/usr/bin/terraform'
        SERVER_NAME = "34.59.68.175"
    }
    tools {
        jdk 'jdk17'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Cloning the kepler frontend repository') {
            steps {
                sshagent(['kepler-ssh']) {  // Remplace par l'ID de la credential SSH
                    // sh 'git clone git@github.com:Tanit-Lab/kepler-frontend.git /var/lib/jenkins/workspace/Kepler-frontend/kepler-frontend/'
                    checkout scmGit(branches: [[name: '*/main']], extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'kepler-frontend']], userRemoteConfigs: [[credentialsId: 'kepler-ssh', url: 'git@github.com:Tanit-Lab/kepler-frontend.git']])
                }
            }
        }
        
        // //for the frontend
        stage('Set Permissions for kepler-frontend') {
            steps {
                script {
                    sh "sudo chown -R jenkins:jenkins ${WORKSPACE}/kepler-frontend"
                    sh "sudo chmod -R 755 ${WORKSPACE}/kepler-frontend"
                    sh "ls -l ${WORKSPACE}/kepler-frontend"
                }
            }
        }
        stage('Modifying NGINX config for kepler-frontend') {
            steps {
                script {
                    def nginxConfFile = "${WORKSPACE}/kepler-frontend/nginx.conf"
                    sh "sed -i 's/server_name .*/server_name ${SERVER_NAME};/' ${nginxConfFile}"
                    sh "cat ${nginxConfFile}"
                }
            }
        }
        stage('Modifier environment.prod.ts') {
            steps {
                script {
                    def envFile = "${WORKSPACE}/kepler-frontend/src/environments/environment.prod.ts"
                    sh """
                        sed -i 's|34.121.4.38|${SERVER_NAME}|g' ${envFile}
                        sed -i 's|35.222.175.109|${SERVER_NAME}|g' ${envFile}
                    """
                    sh "cat ${envFile}"
                }
            }
        }
        // configuration de smarketyrs
        stage('Modifying NGINX config for smarketyrs') {
            steps {
                script {
                    def nginxConfFile = "${WORKSPACE}/kepler-frontend/nginx-smarket.conf"
                    sh "sed -i 's/server_name .*/server_name ${SERVER_NAME};/' ${nginxConfFile}"
                    sh "cat ${nginxConfFile}"
                }
            }
        }
        stage('Modifier environment.smarket.ts') {
            steps {
                script {
                    def envFile = "${WORKSPACE}/kepler-frontend/src/environments/environment.smarket.ts"
                    sh """
                        sed -i 's|34.121.4.38|${SERVER_NAME}|g' ${envFile}
                        sed -i 's|35.222.175.109|${SERVER_NAME}|g' ${envFile}
                    """
                    sh "cat ${envFile}"
                }
            }
        }
        stage('Building Docker Image (kepler-frontend)') {
            steps {
                script {
                    sh """
                        sudo docker build -t kepler-frontend:latest ${WORKSPACE}/kepler-frontend
                    """
                }
            }
        }
        stage('Deploying Container (kepler-frontend)') {
            steps {
                script {
                    sh """
                        sudo docker stop kepler-frontend || true
                        sudo docker rm kepler-frontend || true
                        sudo docker-compose -f ${WORKSPACE}/kepler-frontend/docker-compose-front.yml up -d --build
                    """
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''
                        set -e
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=Kepler-frontend \
                        -Dsonar.projectKey=Kepler-frontend
                    '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token'
                }
            }
        }
    }
}

///////////////////////////////////////

pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'sonarqube-scanner'
        TERRAFORM_HOME = '/usr/bin/terraform'
        SERVER_NAME = "34.59.68.175"
    }

    tools {
        jdk 'jdk17'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
                // checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'kepler-ssh', url: 'git@github.com:Tanit-Lab/kepler-backend.git']])
            }
        }
        stage('Cloning the kepler backend repository') {
            steps {
                sshagent(['kepler-ssh']) {  // Remplace par l'ID de la credential SSH
                    sh 'git clone git@github.com:Tanit-Lab/kepler-backend.git /var/lib/jenkins/workspace/Kepler-backend/kepler-backend/'
                }
            }
        }
        stage('Set Permissions for kepler-backend') {
            steps {
                script {
                    sh "sudo chown -R jenkins:jenkins ${WORKSPACE}/kepler-backend"
                    sh "sudo chmod -R 755 ${WORKSPACE}/kepler-backend"
                    sh "ls -l ${WORKSPACE}/kepler-backend"
                }
            }
        }
        stage('Modifier envfile pour kepler-backend') {
            steps {
                script {
                    def configFile = "${WORKSPACE}/kepler-backend/docker-config/envfile" 
                    
                    // Remplacer BACKEND_URL et EMAIL_URL dans le fichier
                    sh """
                        sed -i 's|^BACKEND_URL *=.*|BACKEND_URL = "http://${SERVER_NAME}:3001"|' ${configFile}
                        sed -i 's|^EMAIL_URL *=.*|EMAIL_URL = "http://${SERVER_NAME}/"|' ${configFile}
                        cat ${configFile}
                    """
                }
            }
        }
        stage('Building Docker Image (kepler-backend)') {
            steps {
                script {
                    sh """
                        sudo docker build -t kepler-backend:latest ${WORKSPACE}/kepler-backend
                    """
                }
            }
        }
        stage('Deploying Container (kepler-backend)') {
            steps {
                script {
                    sh """
                        sudo docker stop kepler-backend || true
                        sudo docker rm kepler-backend || true
                        sudo docker-compose -f ${WORKSPACE}/kepler-backend/docker-compose-backend.yml up -d --build
                    """
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''
                        set -e
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=Kepler-backend \
                        -Dsonar.projectKey=Kepler-backend
                    '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token'
                }
            }
        }
    }
}
///////////////////////////
pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'sonarqube-scanner'
        TERRAFORM_HOME = '/usr/bin/terraform'
        SERVER_NAME = "34.59.68.175"
    }

    tools {
        jdk 'jdk17'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
                // checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'kepler-ssh', url: 'git@github.com:Tanit-Lab/kepler-bd-api.git']])
            }
        }
        stage('Cloning the kepler big data api repository') {
            steps {
                sshagent(['kepler-ssh']) {  // Remplace par l'ID de la credential SSH
                    sh 'git clone git@github.com:Tanit-Lab/kepler-bd-api.git /var/lib/jenkins/workspace/Kepler-bd-api/kepler-bd-api/'
                }
            }
        }
        stage('Set Permissions for kepler-bd-api ') {
            steps {
                script {
                    sh "sudo chown -R jenkins:jenkins ${WORKSPACE}/kepler-bd-api"
                    sh "sudo chmod -R 755 ${WORKSPACE}/kepler-bd-api"
                    sh "ls -l ${WORKSPACE}/kepler-bd-api"
                }
            }
        }
        stage('Modifier external ip et backend urls') {
            steps {
                script {
                    def configFile = "${WORKSPACE}/kepler-bd-api/.env.sample" 
                    sh """
                        sed -i 's|^EXTERNAL_IP *=.*|EXTERNAL_IP="${SERVER_NAME}"|' ${configFile}
                        sed -i 's|^BACKEND_URL *=.*|BACKEND_URL="http://${SERVER_NAME}:5001"|' ${configFile}
                        cat ${configFile}
                    """
                }
            }
        }
        stage('Modifying NGINX config for kepler-bd-api') {
            steps {
                script {
                    def nginxConfFile1 = "${WORKSPACE}/kepler-bd-api/conf/nginx/keplerbigdata"
                    def nginxConfFile2 = "${WORKSPACE}/kepler-bd-api/conf/nginx/keplerfront"
                    sh "sed -i 's/server_name .*/server_name ${SERVER_NAME};/' ${nginxConfFile1}"
                    sh "cat ${nginxConfFile1}"
                    sh "sed -i 's/server_name .*/server_name ${SERVER_NAME};/' ${nginxConfFile2}"
                    sh "cat ${nginxConfFile2}"
                }
            }
        }
        stage('Modifying docker-config') {
            steps {
                script {
                    def dockerConfigFile = "${WORKSPACE}/kepler-bd-api/conf/docker-config/bd-api"
                    sh "sed -i 's/server_name .*/server_name $SERVER_NAME;/' ${dockerConfigFile}"
                    sh "cat ${dockerConfigFile}"
                }
            }
        }
        stage('Upload Jars') {
            steps {
                script {
                    sh """
                        sudo -i bash -c '
                        source /etc/profile &&
                        export HADOOP_HOME=/opt/hadoop &&
                        export PATH=\$HADOOP_HOME/bin:\$PATH &&
                        /var/lib/jenkins/workspace/Kepler-bd-api/kepler-bd-api/scripts/upload-jars.sh
                        '
                    """
                }
            }
        }
        stage('Building Docker Image (kepler-bd-api)') {
            steps {
                script {
                    sh """
                        sudo docker build -t kepler-bd-api:latest ${WORKSPACE}/kepler-bd-api
                    """
                }
            }
        }
        stage('Deploying Container (kepler-bd-api)') {
            steps {
                script {
                    sh """
                        sudo docker stop kepler-bd-api || true
                        sudo docker rm kepler-bd-api || true
                        sudo docker-compose -f ${WORKSPACE}/kepler-bd-api/docker-compose-bd-api.yml up -d --build
                    """
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''
                        set -e
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=Kepler-bd-api \
                        -Dsonar.projectKey=Kepler-bd-api
                    '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token'
                }
            }
        }
    }
}
