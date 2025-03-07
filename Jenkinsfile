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
        // stage('Clean Workspace') {
        //     steps {
        //         cleanWs()
        //     }
        // }
        stage('Checkout Repositories') {
            steps {
                script {
                    // Si tu veux vraiment faire un checkout après avoir cloné, tu peux procéder ici.
                    // Cependant, si tu utilises `sshagent` et `git clone`, il n'est généralement pas nécessaire de faire un checkout supplémentaire.
                    dir('kepler-frontend') {
                        sh 'git checkout main'
                    }
                    dir('kepler-backend') {
                        sh 'git checkout main'
                    }
                    dir('kepler-bd-api') {
                        sh 'git checkout main'
                    }
                }
            }
        }
        stage('Check for Changes') {
            steps {
                script {
                    // Initialize flags
                    env.FRONTEND_CHANGED = 'false'
                    env.BACKEND_CHANGED = 'false'
                    env.BDAPI_CHANGED = 'false'

                    // Check for changes in the frontend repository
                    dir('kepler-frontend') {
                        sh 'git fetch'
                        def frontendChanges = sh(script: 'git diff --name-only origin/main', returnStdout: true).trim()
                        echo "Frontend Changed Files: ${frontendChanges}"
                        if (frontendChanges) {
                            env.FRONTEND_CHANGED = 'true'
                        }
                    }

                    // Check for changes in the backend repository
                    dir('kepler-backend') {
                        sh 'git fetch'
                        def backendChanges = sh(script: 'git diff --name-only origin/main', returnStdout: true).trim()
                        echo "Backend Changed Files: ${backendChanges}"
                        if (backendChanges) {
                            env.BACKEND_CHANGED = 'true'
                        }
                    }

                    // Check for changes in the BD API repository
                    dir('kepler-bd-api') {
                        sh 'git fetch'
                        def bdApiChanges = sh(script: 'git diff --name-only origin/main', returnStdout: true).trim()
                        echo "BD-API Changed Files: ${bdApiChanges}"
                        if (bdApiChanges) {
                            env.BDAPI_CHANGED = 'true'
                        }
                    }

                    // Output the flags
                    echo "Frontend Changed: ${env.FRONTEND_CHANGED}"
                    echo "Backend Changed: ${env.BACKEND_CHANGED}"
                    echo "BD-API Changed: ${env.BDAPI_CHANGED}"
                }
            }
        }

        // stage('Cloning the kepler frontend repository') {
        //     when {
        //         environment name: 'FRONTEND_CHANGED', value: 'true'
        //     }
        //     steps {
        //         sshagent(['kepler-ssh']) {  // Remplace par l'ID de la credential SSH
        //             sh 'git clone git@github.com:Tanit-Lab/kepler-frontend.git /var/lib/jenkins/workspace/Kepler_Project/kepler-frontend/'
        //         }
        //     }
        // }
        
        // // //for the frontend
        // stage('Set Permissions for kepler-frontend') {
        //     when {
        //         environment name: 'FRONTEND_CHANGED', value: 'true'
        //     }            
        //     steps {
        //         script {
        //             sh "sudo chown -R jenkins:jenkins ${WORKSPACE}/kepler-frontend"
        //             sh "sudo chmod -R 755 ${WORKSPACE}/kepler-frontend"
        //             sh "ls -l ${WORKSPACE}/kepler-frontend"
        //         }
        //     }
        // }
        // stage('Modifying NGINX config for kepler-frontend') {
        //     when {
        //         environment name: 'FRONTEND_CHANGED', value: 'true'
        //     }            
        //     steps {
        //         script {
        //             def nginxConfFile = "${WORKSPACE}/kepler-frontend/nginx.conf"
        //             sh "sed -i 's/server_name .*/server_name ${SERVER_NAME};/' ${nginxConfFile}"
        //             sh "cat ${nginxConfFile}"
        //         }
        //     }
        // }
        // stage('Modifier environment.prod.ts') {
        //     when {
        //         environment name: 'FRONTEND_CHANGED', value: 'true'
        //     }            
        //     steps {
        //         script {
        //             def envFile = "${WORKSPACE}/kepler-frontend/src/environments/environment.prod.ts"
        //             sh """
        //                 sed -i 's|34.121.4.38|${SERVER_NAME}|g' ${envFile}
        //                 sed -i 's|35.222.175.109|${SERVER_NAME}|g' ${envFile}
        //             """
        //             sh "cat ${envFile}"
        //         }
        //     }
        // }
        // stage('Building Docker Image (kepler-frontend)') {
        //     when {
        //         environment name: 'FRONTEND_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             sh """
        //                 sudo docker build -t kepler-frontend:latest ${WORKSPACE}/kepler-frontend
        //             """
        //         }
        //     }
        // }
        // stage('Deploying Container (kepler-frontend)') {
        //     when {
        //         environment name: 'FRONTEND_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             sh """
        //                 sudo docker stop kepler-frontend || true
        //                 sudo docker rm kepler-frontend || true
        //                 sudo docker-compose -f ${WORKSPACE}/kepler-frontend/docker-compose-front.yml up -d --build
        //             """
        //         }
        //     }
        // }
        // //for the backend
        // stage('Cloning the kepler backend repository') {
        //     when {
        //         environment name: 'BACKEND_CHANGED', value: 'true'
        //     }            
        //     steps {
        //         sshagent(['kepler-ssh']) {  // Remplace par l'ID de la credential SSH
        //             sh 'git clone git@github.com:Tanit-Lab/kepler-backend.git /var/lib/jenkins/workspace/Kepler_Project/kepler-backend/'
        //         }
        //     }
        // }
        // stage('Set Permissions for kepler-backend') {
        //     when {
        //         environment name: 'BACKEND_CHANGED', value: 'true'
        //     }           
        //     steps {
        //         script {
        //             sh "sudo chown -R jenkins:jenkins ${WORKSPACE}/kepler-backend"
        //             sh "sudo chmod -R 755 ${WORKSPACE}/kepler-backend"
        //             sh "ls -l ${WORKSPACE}/kepler-backend"
        //         }
        //     }
        // }

        // stage('Modifier envfile pour kepler-backend') {
        //     when {
        //         environment name: 'BACKEND_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             def configFile = "${WORKSPACE}/kepler-backend/docker-config/envfile" 
                    
        //             // Remplacer BACKEND_URL et EMAIL_URL dans le fichier
        //             sh """
        //                 sed -i 's|^BACKEND_URL *=.*|BACKEND_URL = "http://${SERVER_NAME}:3001"|' ${configFile}
        //                 sed -i 's|^EMAIL_URL *=.*|EMAIL_URL = "http://${SERVER_NAME}/"|' ${configFile}
        //                 cat ${configFile}
        //             """
        //         }
        //     }
        // }

        // stage('Building Docker Image (kepler-backend)') {
        //     when {
        //         environment name: 'BACKEND_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             sh """
        //                 sudo docker build -t kepler-backend:latest ${WORKSPACE}/kepler-backend
        //             """
        //         }
        //     }
        // }
        // stage('Deploying Container (kepler-backend)') {
        //     when {
        //         environment name: 'BACKEND_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             sh """
        //                 sudo docker stop kepler-backend || true
        //                 sudo docker rm kepler-backend || true
        //                 sudo docker-compose -f ${WORKSPACE}/kepler-backend/docker-compose-backend.yml up -d --build
        //             """
        //         }
        //     }
        // }
        // ///BIG DATA API
        // stage('Cloning the kepler big data api repository') {
        //     when {
        //         environment name: 'BDAPI_CHANGED', value: 'true'
        //     }
        //     steps {
        //         sshagent(['kepler-ssh']) {  // Remplace par l'ID de la credential SSH
        //             sh 'git clone git@github.com:Tanit-Lab/kepler-bd-api.git /var/lib/jenkins/workspace/Kepler_Project/kepler-bd-api/'
        //         }
        //     }
        // }
        // stage('Set Permissions for kepler-bd-api ') {
        //     when {
        //         environment name: 'BDAPI_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             sh "sudo chown -R jenkins:jenkins ${WORKSPACE}/kepler-bd-api"
        //             sh "sudo chmod -R 755 ${WORKSPACE}/kepler-bd-api"
        //             sh "ls -l ${WORKSPACE}/kepler-bd-api"
        //         }
        //     }
        // }
        // stage('Modifier external ip et backend urls') {
        //     when {
        //         environment name: 'BDAPI_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             def configFile = "${WORKSPACE}/kepler-bd-api/.env.sample" 
                    
        //             sh """
        //                 sed -i 's|^EXTERNAL_IP *=.*|EXTERNAL_IP="${SERVER_NAME}"|' ${configFile}
        //                 sed -i 's|^BACKEND_URL *=.*|BACKEND_URL="http://${SERVER_NAME}:5001"|' ${configFile}
        //                 cat ${configFile}
        //             """
        //         }
        //     }
        // }
        // stage('Modifying NGINX config for kepler-bd-api') {
        //     when {
        //         environment name: 'BDAPI_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             def nginxConfFile1 = "${WORKSPACE}/kepler-bd-api/conf/nginx/keplerbigdata"
        //             def nginxConfFile2 = "${WORKSPACE}/kepler-bd-api/conf/nginx/keplerfront"
        //             sh "sed -i 's/server_name .*/server_name ${SERVER_NAME};/' ${nginxConfFile1}"
        //             sh "cat ${nginxConfFile1}"
        //             sh "sed -i 's/server_name .*/server_name ${SERVER_NAME};/' ${nginxConfFile2}"
        //             sh "cat ${nginxConfFile2}"
        //         }
        //     }
        // }
        // stage('Modifying docker-config') {
        //     when {
        //         environment name: 'BDAPI_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             def dockerConfigFile = "${WORKSPACE}/kepler-bd-api/conf/docker-config/bd-api"
        //             sh "sed -i 's/server_name .*/server_name $SERVER_NAME;/' ${dockerConfigFile}"
        //             sh "cat ${dockerConfigFile}"
        //         }
        //     }
        // }
        // stage('Upload Jars') {
        //     when {
        //         environment name: 'BDAPI_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             sh """
        //                 sudo -i bash -c '
        //                 source /etc/profile &&
        //                 export HADOOP_HOME=/opt/hadoop &&
        //                 export PATH=\$HADOOP_HOME/bin:\$PATH &&
        //                 /var/lib/jenkins/workspace/Kepler_Project/kepler-bd-api/scripts/upload-jars.sh
        //                 '
        //             """
        //         }
        //     }
        // }
        // stage('Building Docker Image (kepler-bd-api)') {
        //     when {
        //         environment name: 'BDAPI_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             sh """
        //                 sudo docker build -t kepler-bd-api:latest ${WORKSPACE}/kepler-bd-api
        //             """
        //         }
        //     }
        // }
        // stage('Deploying Container (kepler-bd-api)') {
        //     when {
        //         environment name: 'BDAPI_CHANGED', value: 'true'
        //     }
        //     steps {
        //         script {
        //             sh """
        //                 sudo docker stop kepler-bd-api || true
        //                 sudo docker rm kepler-bd-api || true
        //                 sudo docker-compose -f ${WORKSPACE}/kepler-bd-api/docker-compose-bd-api.yml up -d --build
        //             """
        //         }
        //     }
        // }
        
        // stage('SonarQube Analysis') {
        //     steps {
        //         withSonarQubeEnv('SonarQube-Server') {
        //             sh '''
        //                 set -e
        //                 $SCANNER_HOME/bin/sonar-scanner \
        //                 -Dsonar.projectName=Kepler_Project \
        //                 -Dsonar.projectKey=Kepler_Project
        //             '''
        //         }
        //     }
        // }
        // stage('Quality Gate') {
        //     steps {
        //         script {
        //             waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token'
        //         }
        //     }
        // }
    }
}