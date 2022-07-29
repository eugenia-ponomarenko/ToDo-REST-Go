pipeline {
    agent any
    tools {
        go 'go 1.18'
    }
    environment {
        GO114MODULE = 'on'
        CGO_ENABLED = 0 
        GOPATH      = "${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_ID}"
        dockerHubPwd   = credentials('dockerHub')
        dockerHubUser  = "eugenia1p"
        imagename   = "eugenia1p/todo_go_rest"
        dockerImage = ''

    }
    stages {      
         stage('Git clone'){
            steps{
                git url: 'https://github.com/eugenia-ponomarenko/ToDo-REST-Go.git', credentialsId: 'github', branch: 'cd_pipeline'
            }
        }
        
        stage('Docker Build') {
          agent any
          steps {
            sh 'docker build -t eugenia1p/todo_go_rest:$BUILD_NUMBER ../ToDo_CI/.'
          }
        }

        stage('Test') {
            steps {
                withEnv(["PATH+GO=${GOPATH}/bin"]){
                    echo 'Running vetting'
                    sh 'go vet .'
                    echo 'Running test'
                    sh 'go test -v ./...'
                }
            }
        }
        
        stage('Docker Push') {
          agent any
          steps {
            withCredentials([usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
              sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
              sh 'docker push eugenia1p/todo_go_rest:$BUILD_NUMBER'
            }
          }
        }
        
    }
}
