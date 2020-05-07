pipeline {

    agent none

    environment {
        
        NODE_ENV="homologacao"
        AWS_ACCESS_KEY=""
        AWS_SECRET_ACCESS_KEY=""
        AWS_SDK_LOAD_CONFIG="0"
        BUCKET_NAME="digitalhouse-desligaoar-homolog"
        REGION="sa-east-1" 
        PERMISSION=""
        ACCEPTED_FILE_FORMATS_ARRAY=""
        VERSION="1.0.0"
    }


    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    triggers {
        cron('@daily')
    }

    stages{
        stage("Build, Test and Push Docker Image") {
            agent {  
                node {
                    label 'master'
                }
            }
            stages {

                stage('Clone repository') {
                    steps {
                        script {
                            if(env.GIT_BRANCH=='origin/master'){
                                checkout scm
                            }
                            sh('printenv | sort')
                            echo "My branch is: ${env.GIT_BRANCH}"
                        }
                    }
                }
                stage('Build image'){       
                    steps {
                        script {
                            print "Environment will be : ${env.NODE_ENV}"
                            docker.build("digitalhouse-devops:latest")
                        }
                    }
                }

                stage('Test image') {
                    steps {
                        script {

                            docker.image("digitalhouse-devops:latest").withRun('-p 8030:3000') { c ->
                                sh 'docker ps'
                                sh 'sleep 10'
                                sh 'curl http://127.0.0.1:8030/api/v1/healthcheck'
                                
                            }
                    
                        }
                    }
                }

                stage('Docker push') {
                    steps {
                        echo 'Push latest para AWS ECR'
                        script {
                            docker.withRegistry('https://690516794798.dkr.ecr.us-east-1.amazonaws.com', 'ecr:us-east-1:ecr-digitalhouse-neon') {
                                docker.image('digitalhouse-devops').push()
                            }
                        }
                    }
                }
            }
        }

        stage('Deploy to DEV') {
            agent {  
                node {
                    label 'HOMOLOG'
                }
            }

            steps { 
                script {
                    if(env.GIT_BRANCH=='origin/master'){
 
                        docker.withRegistry('https://690516794798.dkr.ecr.us-east-1.amazonaws.com', 'ecr:us-east-1:ecr-digitalhouse-neon') {
                            docker.image('digitalhouse-devops').pull()
                        }

                        echo 'Deploy para Desenvolvimento'
                        sh "hostname"
                        sh "docker stop app1"
                        sh "docker rm app1"
                        
                        withCredentials([[$class:'AmazonWebServicesCredentialsBinding', credentialsId: 'homolog_s3']]) {
                        
                           // sh "docker run -d --name app1 -p 8030:3000 690516794798.dkr.ecr.us-east-1.amazonaws.com/digitalhouse-devops:latest"
                           // sh "docker run -d -p 9080:80 -e NODE_ENV=production -e AWS_ACCESS_KEY=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e BUCKET_NAME= nginx:latest"
                            sh "docker run -d -p 80:3000 -e NODE_ENV=production -e AWS_ACCESS_KEY="" -e AWS_SECRET_ACCESS_KEY="" -e BUCKET_NAME="" --name app_homolog digitalhouse/pi:1.0.0 "
                            sh "docker ps"
                            sh 'sleep 10'
                            sh 'curl http://127.0.0.1:8030/api/v1/healthcheck'
                        }

                    }
                }
            }

        }

        stage('Deploy to Producao') {
            agent {  
                node {
                    label 'PROD'
                }
            }

            steps { 
                script {
                    if(env.GIT_BRANCH=='origin/master'){
 
                        environment {

                            NODE_ENV="producao"
                            AWS_ACCESS_KEY="123456"
                            AWS_SECRET_ACCESS_KEY="asdfghjkkll"
                            AWS_SDK_LOAD_CONFIG="0"
                            BUCKET_NAME="digitalhouse-desligaoar-producao"
                            REGION="sa-east-1" 
                            PERMISSION=""
                            ACCEPTED_FILE_FORMATS_ARRAY=""
                        }


                        docker.withRegistry('https://933273154934.dkr.ecr.us-east-1.amazonaws.com', 'ecr:us-east-1:awsdvops') {
                            docker.image('digitalhouse-devops').pull()
                        }

                        echo 'Deploy para Desenvolvimento'
                        sh "hostname"
                        sh "docker stop app1"
                        sh "docker rm app1"
                        sh "docker run -d --name app1 -p 8030:3000 933273154934.dkr.ecr.us-east-1.amazonaws.com/digitalhouse-devops:latest"
                        sh "docker ps"
                        sh 'sleep 10'
                        sh 'curl http://127.0.0.1:8030/api/v1/healthcheck'

                    }
                }
            }

        }

    }
}
