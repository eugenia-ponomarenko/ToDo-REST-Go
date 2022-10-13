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

        stage('Terraform apply lb and vpc'){
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId:'AWS_EC2_S3',
                 accessKeyVariable: 'AWS_ACCESS_KEY', secretKeyVariable: 'AWS_SECRET_KEY']]){
                    sh '''
                    cd ./Terraform/lb_vpc_rds/ 
                    terraform init
                    terraform apply -var db_password="$DB_PASSWORD" -var jenkins_public_ip="$jenkins_public_ip" --auto-approve -no-color
                    '''
                }
            }
        }

        stage('Migrate DB schema'){
            steps{
                script {
                    env.DB_ENDPOINT = sh(returnStdout: true, script: '''
                    cd ./Terraform/lb_vpc_rds/
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

        stage('Change localhost to remote public IP'){
            steps{
                script {
                    env.Public_IP = sh(returnStdout: true, script: '''
                    cd ./Terraform
                    terraform output lb_dns_name | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'
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
                sh 'env GOOS=linux GOARCH=arm64 go build -o todo-app ./cmd/main.go '
            }
        }

        stage('Deploy image on DockerHub') {
            steps{
                script {
                    dockerImage = docker.build registry
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push('arm64')
                    }
                }
            }
        }
        
        stage('Remove Unused docker image') {       
            steps{          
                sh "docker rmi $registry:arm64" 
            }     
        }

        stage('Get lb_target_id from Terrafrom/lb_vpc_rds/'){
            steps{
                script{
                    env.lb_target_id = sh(returnStdout: true, script: '''
                        cd ./Terraform/lb_vpc_rds/
                        terraform output lb_target_id | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'
                        ''').trim()
                }
            }
        }
        
        stage('Get ecs_sg_id from Terrafrom/lb_vpc_rds/'){
            steps{
                script{
                    env.ecs_sg_id = sh(returnStdout: true, script: '''
                        cd ./Terraform/lb_vpc_rds/
                        terraform output ecs_sg_id | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'
                        ''').trim()
                }
            }
        }
        
        stage('Get public_subnet_0 from Terrafrom/lb_vpc_rds/'){
            steps{
                sript{
                    env.public_subnet_0 = sh(returnStdout: true, script: '''
                        cd ./Terraform/lb_vpc_rds/
                        terraform output public_subnet_0 | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'
                        ''').trim()
                }
            }
        }
        
        stage('Get public_subnet_1 from Terrafrom/lb_vpc_rds/'){
            steps{
                script{
                    env.public_subnet_1 = sh(returnStdout: true, script: '''
                        cd ./Terraform/lb_vpc_rds/
                        terraform output public_subnet_1 | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'
                        ''').trim()
                }
            }
        }
        
        stage('Get public_subnet_2 from Terrafrom/lb_vpc_rds/'){
            steps{
                script{
                    env.public_subnet_2 = sh(returnStdout: true, script: '''
                        cd ./Terraform/lb_vpc_rds/
                        terraform output public_subnet_2 | sed 's/.\\(.*\\)/\\1/' | sed 's/\\(.*\\)./\\1/'
                        ''').trim()
                }
            }
        }

        stage('Terraform apply RDS and ECS'){
            steps{
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId:'AWS_EC2_S3',
                 accessKeyVariable: 'AWS_ACCESS_KEY', secretKeyVariable: 'AWS_SECRET_KEY']]){
                    sh '''
                    cd ./Terraform/ecs/ 
                    terraform init
                    terraform apply \
                    -var lb_target_id="$lb_target_id" \
                    -var ecs_sg_id="$ecs_sg_id" \
                    -var public_subnet_0="$public_subnet_0" \
                    -var public_subnet_1="$public_subnet_1" \
                    -var public_subnet_2="$public_subnet_2" \
                    --auto-approve -no-color
                    '''
                }
            }
        }
    }
}


// output vpc_id
