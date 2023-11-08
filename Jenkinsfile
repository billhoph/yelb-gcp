pipeline {
  agent any
  stages {
    stage('Git clone') {
      steps {
        sh 'git clone https://github.com/billhoph/yelb-jenkins.git'
      }
    }

    stage('Source Code Scanning') {
      steps {
        sh '''cd yelb-jenkins
checkov -d . '''
      }
    }

  }
}