pipeline {
    agent any
    tools {
        dockerTool 'docker'
    
    }
    
    environment {
        registry = "eugenia1p/todo_rest"
        registryCredential = 'dockerHub' 
        DB_PASSWORD = credentials('db_password')
        TODO_KEY  = credentials('todo_key')
        Public_IP = ''
        dockerImage = ''
    }
    
    stages {
        
        stage('Set Terraform path') {
            steps {
                script {
                    def tfHome = tool name: 'terraform'
                    env.PATH = "${tfHome}:${env.PATH}"
                }
                sh 'terraform --version'
            }
        }

        stage('Git clone'){
            steps{
                git url: 'https://github.com/eugenia-ponomarenko/ToDo-REST-Go.git', credentialsId: 'github', branch: 'main'
            }
        }
        
        stage('Copy email credentials and ansible_ssh_key.pem') {
            steps {
                script {
                    def exists = fileExists './.ssh'
                    if (exists) {
                        sh "cp \$TODO_KEY ./.ssh/"
                        sh "chmod 600 ./.ssh/todo_key.pem"
                    } else {
                        sh "mkdir ./.ssh"
                        sh "cp \$TODO_KEY ./.ssh/"
                        sh "chmod 600 ./.ssh/todo_key.pem"
                    }
                }
            }
        }

        stage('Terraform apply'){
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId:'AWS_TODO',
                 accessKeyVariable: 'AWS_ACCESS_KEY', secretKeyVariable: 'AWS_SECRET_KEY']]){
                    sh "cd ./Terraform; terraform apply --auto-approve -no-color"
                }
            }
        }
        
        stage('Add Public IP to Ansible config and change localhost to remote public IP'){
            steps{
                script {
                    sh '''
                    cd ./Terraform
                    Public_IP=`terraform output ip | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'`
                    sed -i -e "s/Public_IP/$Public_IP/g" ../Ansible/inventory.yml
                    sed -i -e "s/localhost/$Public_IP/g" ../docs/*
                    sed -i -e "s/localhost/$Public_IP/g" ../cmd/main.go
                    '''
                }
            }
        }
        
        stage('Change image name and DB password in docker-compose.yml'){
            steps{
                script {
                    sh '''
                    sed -i -e "s#image: eugenia1p/todo_go_rest#image: $registry#g" ./docker-compose.yml
                    sed -i -e "s/DB_PASSWORD=qwerty/DB_PASSWORD=$DB_PASSWORD/g" ./docker-compose.yml
                    sed -i -e "s/POSTGRES_PASSWORD=qwerty/POSTGRES_PASSWORD=$DB_PASSWORD/g" ./docker-compose.yml
                    '''
                }
            }
        }
        
        stage('Create .env'){
            steps {
                sh 'echo "DB_PASSWORD=$DB_PASSWORD" >> .env'
            }
        }
        
        stage('Build docker image') {
            steps{
                script {
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"    
                }
            }
        }
        
        stage('Push docker image') {
            steps{
                script {
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
            }     
        }
        
        stage('Ansible-playbook'){
            steps{
                sh 'cd ./Ansible; /usr/local/bin/ansible-playbook $JENKINS_HOME/workspace/$JOB_NAME/Ansible/playbook.yaml --inventory-file $JENKINS_HOME/workspace/$JOB_NAME/Ansible/inventory.yml '
            }
        }
        
        stage('Migrate DB'){
            steps{
                script {
                    sh '''
                    cd ./Terraform
                    Public_IP=`terraform output ip | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'`
                    /usr/local/bin/migrate -path ../schema -database "postgres://postgres:$DB_PASSWORD@$Public_IP:5432/postgres?sslmode=disable" up
                    '''
                }
            }
        }

    }
}
