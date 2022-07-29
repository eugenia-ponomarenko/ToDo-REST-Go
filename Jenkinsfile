pipeline {
    agent any
    tools {
        dockerTool 'docker'
    
    }
    
    environment {
        imageName = "eugenia1p/todo_go_rest"
        registryCredential = 'dockerHub' 
        DB_PASSWORD = credentials('db_password')
        TODO_KEY  = credentials('todo_key')
        Public_IP = ''
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
                git url: 'https://github.com/eugenia-ponomarenko/ToDo-REST-Go.git', credentialsId: 'github', branch: 'cd_pipeline'
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
        
        // stage('Create .env'){
        //     steps {
        //         sh 'echo "DB_PASSWORD=$DB_PASSWORD" >> .env'
        //     }
        // }
        
        // stage('Deploy our image') {
        //     steps{
        //         script {
        //             dockerImage = docker.build imageName
        //             docker.withRegistry('', "$registryCredential") {
        //                 dockerImage.push("$BUILD_NUMBER")
        //                 dockerImage.push('latest')
        //             }
        //         }
        //     }
        // }

        stage('Terraform apply'){
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId:'AWS_TODO',
                 accessKeyVariable: 'AWS_ACCESS_KEY', secretKeyVariable: 'AWS_SECRET_KEY']]){
                    sh "cd ./Terraform; terraform init"
                    sh "cd ./Terraform; terraform apply --auto-approve -no-color"
                }
            }
        }
        
        stage('Add Public IP to Ansible config'){
            steps{
                script {
                    sh '''
                    cd ./Terraform
                    Public_IP=`terraform output ip | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'`
                    echo $Public_IP
                    sed -i -e "s/Public_IP/$Public_IP/g" ../Ansible/inventory.yml
                    '''
                }
            }
        }
        
        stage('Ansible-playbook'){
            steps{
                sh 'cd ./Ansible; /usr/local/bin/ansible-playbook $JENKINS_HOME/workspace/$JOB_NAME/Ansible/playbook.yaml --inventory-file $JENKINS_HOME/workspace/$JOB_NAME/Ansible/inventory.yml '
            }
        }
        
        stage('Migrate DB'){
            steps{
                sh '/usr/local/bin/migrate -path ./schema -database "postgres://postgres:$DB_PASSWORD@$Public_IP:5432/postgres?sslmode=disable" up'
            }
        }

    }
}
