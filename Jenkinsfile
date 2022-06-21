pipeline {
    agent any
    
    environment {
        // AWS_ACCESS_KEY_ID        = credentials('TF_AWS_ACCESS_KEY_ID')
        // AWS_SECRET_ACCESS_KEY    = credentials('TF_AWS_SECRET_ACCESS_KEY')
        DB_PASSWORD              = 'qwerty'
        TODO_KEY              = credentials('todo_key')
    }
    
    stages {

        stage('Git clone'){
            steps{
                git url: 'https://github.com/eugenia-ponomarenko/ToDo-REST-Go.git', credentialsId: 'github', branch: 'cd_pipeline'
            }
        }
        
        stage('Copy email credentials and ansible_ssh_key.pem') {
            steps {
            //   sh "mkdir ./.ssh"
              sh "cp \$TODO_KEY ./.ssh/"
              sh "chmod 600 ./.ssh/todo_key.pem"
            }
        }
        

        stage('Terraform apply'){
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId:'AWS_TF',
                 accessKeyVariable: 'AWS_ACCESS_KEY', secretKeyVariable: 'AWS_SECRET_KEY']]){
                    sh "cd ./Terraform; terraform init"
                    sh "cd ./Terraform; terraform apply --auto-approve"
                }
            }
        }
        
        stage('Add Public IP to Ansible config'){
            steps{
                script {
                        sh '''#!/bin/bash
                        cd ./Terraform
                        Public_IP=`terraform output ip | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'`
                        sed -ie "s/Public_IP/$Public_IP/g" ../Ansible/inventory.yml 
                        '''
                }
            }
        }
        
        stage('Ansible-playbook'){
            steps{
                sh 'cd ./Ansible; ansible-playbook playbook.yaml'
            }
        }
        
        stage('Migrate DB'){
            steps{
                sh 'migrate -path ./schema -database "postgres://postgres:$DB_PASSWORD@$Public_IP:5432/postgres?sslmode=disable" up'
            }
        }

    }
}
