pipeline {
  agent any
  stages {
    stage('Git Checkout') {
      steps {
        sh '''rm -Rf ./yelb-jenkins
git clone https://github.com/billhoph/yelb-jenkins.git
ls ./yelb-jenkins'''
      }
    }

    stage('Code Scanning') {
      steps {
        sh 'checkov -d ./yelb-jenkins --use-enforcement-rules --prisma-api-url https://api.sg.prismacloud.io --bc-api-key $pcskey --repo-id jenkins-demo/code-checking --branch main -o cli -o junitxml --quiet --compact'
      }
    }

    stage('Docker Image Building') {
      parallel {
        stage('Building UI app Image') {
          steps {
            sh 'docker build ./yelb-jenkins/yelb-ui -t harbor.alson.space/jenkins/yelb-ui:1.0'
          }
        }

        stage('Building DB Image') {
          steps {
            sh 'docker build ./yelb-jenkins/yelb-db -t harbor.alson.space/jenkins/yelb-db:1.0'
          }
        }

        stage('Building AppServer Image') {
          steps {
            sh 'docker build ./yelb-jenkins/yelb-appserver -t harbor.alson.space/jenkins/yelb-appserver:1.0'
          }
        }

      }
    }

    stage('Docker Image Scanning') {
      steps {
        sh 'docker images'
      }
    }

  }
  environment {
    pcskey = 'd505ece3-5ac5-4247-b1ff-b95ec4a28816::Sz52YQjmJDo0ESkK7x0n+E/EBZg='
  }
}