pipeline {
  agent any
  stages {
    stage('Git Checkout') {
      parallel {
        stage('Git Checkout') {
          steps {
            sh '''rm -Rf ./yelb-jenkins

git clone https://github.com/billhoph/yelb-jenkins.git
ls ./yelb-jenkins'''
          }
        }

        stage('Clean up Images on Node') {
          steps {
            sh 'docker system prune -a -f'
          }
        }

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

    stage('List Successful Build Images') {
      steps {
        sh 'docker images'
      }
    }

    stage('Scanning Images (UI Image)') {
      steps {
        prismaCloudScanImage(image: 'harbor.alson.space/jenkins/yelb-ui:1.0', resultsFile: 'yelb-ui-scan.json', logLevel: 'error')
      }
    }

  }
  environment {
    pcskey = 'd505ece3-5ac5-4247-b1ff-b95ec4a28816::Sz52YQjmJDo0ESkK7x0n+E/EBZg='
  }
}