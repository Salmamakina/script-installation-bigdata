pipeline {
    agent any
    environment {
        SCANNER_HOME = tool 'sonarqube-scanner'
        TERRAFORM_HOME = '/usr/local/bin/terraform'
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

        stage('Cloning from GitHub') {
            steps {
                git branch: 'main', credentialsId: 'Github-Token', url: 'https://github.com/Salmamakina/terraform_scripts.git'
            }
        }

        // stage('Initialize Terraform') {
        //     steps {
        //         script {
        //             dir('terraform_scripts') {
        //                 sh '${TERRAFORM_HOME} init'
        //             }
        //         }
        //     }
        // }

        // stage('Terraform Plan') {
        //     steps {
        //         script {
        //             dir('terraform_scripts') {
        //                 sh '${TERRAFORM_HOME} plan'
        //             }
        //         }
        //     }
        // }

        // stage('Terraform Apply') {
        //     steps {
        //         script {
        //             dir('terraform_scripts') {
        //                 sh '${TERRAFORM_HOME} apply -auto-approve'
        //             }
        //         }
        //     }
        // }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=Kepler_Project \
                        -Dsonar.projectKey=Kepler_Project
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
