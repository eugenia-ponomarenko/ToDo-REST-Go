pipeline {
    agent any
    tools {
        dockerTool 'docker'
    }
    
    environment {
        registry = "eugenia1p/todo_rest"
        registryCredential = 'dockerHub' 
        DB_PASSWORD = credentials('db_password')
    }
    
    stages {
        stage('Get own public IP'){
            steps{
                script {
                    env.jenkins_public_ip = sh(returnStdout: true, script: 'curl ifconfig.co').trim()
                }
            }
        }


        stage('Terraform apply'){
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId:'AWS_EC2_S3',
                 accessKeyVariable: 'AWS_ACCESS_KEY', secretKeyVariable: 'AWS_SECRET_KEY']]){
                    sh '''
                    export TF_LOG=debug
                    cd ./Terraform 
                    terraform init
                    terraform apply -var db_password="$DB_PASSWORD" --auto-approve -no-color
                    '''
                }
            }
        }

        stage('Migrate DB schema'){
            steps{
                script {
                    env.DB_ENDPOINT = sh(returnStdout: true, script: '''
                    cd ./Terraform
                    terraform output db_endpoint | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/' | sed 's/:5432//g'
                    ''').trim()
                    
                    sh '''
                    migrate -path ./schema -database "postgres://postgres:$DB_PASSWORD@$DB_ENDPOINT:5432/postgres?sslmode=disable" up
                    '''
                }
            }
        }
        
        stage('Create .env'){
            steps {
                sh 'echo "DB_PASSWORD=$DB_PASSWORD" >> .env'
            }
        }

        stage('Change db host in configs to RDS Endpoint'){
            steps{
                script {
                    sh '''
                    sed -i -e "s/host: db/host: $DB_ENDPOINT/g" ./configs/config.yml
                    '''
                }
            }
        }

        stage('Add Public IP to Ansible config and change localhost to remote public IP'){
            steps{
                script {
                    env.Public_IP = sh(returnStdout: true, script: '''
                    cd ./Terraform
                    terraform output ec2_ip | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'
                    ''').trim()

                    sh '''
                    sed -i -e "s/localhost/$Public_IP/g" ./docs/*
                    sed -i -e "s/localhost/$Public_IP/g" ./cmd/main.go
                    '''
                }
            }
        }

        stage('Build executable for app'){
            steps {
                sh 'env GOOS=linux GOARCH=amd64 go build -o todo-app ./cmd/main.go '
            }
        }

        stage('Deploy image on DockerHub') {
            steps{
                script {
                    dockerImage = docker.build registry + ":$BUILD_NUMBER" 
                    docker.withRegistry( '', registryCredential ) {             
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }
        
        stage('Remove Unused docker image') {       
            steps{         
                sh "docker rmi $registry:$BUILD_NUMBER"   
                sh "docker rmi $registry:latest" 
            }     
        }

        stage('Change image name in the Ansible playbook'){
            steps{
                script {
                    sh '''
                    sed -i -e "s#image: eugenia1p/todo_rest#image: $registry#g" ./Ansible/playbook.yml
                    sed -i -e "s#name: eugenia1p/todo_rest#name: $registry#g" ./Ansible/playbook.yml
                    '''
                }
            }
        }
        
        stage('Ansible-playbook'){
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId:'AWS_EC2_S3',
                 accessKeyVariable: 'AWS_ACCESS_KEY', secretKeyVariable: 'AWS_SECRET_KEY']]){
                    ansiblePlaybook(credentialsId: 'todo_app_ssh_eu_north_1',
                                    disableHostKeyChecking: true, 
                                    installation: 'Ansible', 
                                    inventory: 'Ansible/aws_ec2.yml', 
                                    playbook: 'Ansible/playbook.yml')
                }
            }
        }
    }
}
