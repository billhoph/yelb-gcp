pipeline {
  agent any
  stages {
    stage('Git Checkout') {
      steps {
        sh '''rm -Rf ./yelb-sidescan

git clone https://github.com/billhoph/yelb-jenkins.git yelb-sidescan
ls ./yelb-sidescan'''
      }
    }

    stage('Code Scanning') {
      parallel {
        stage('Code Scanning') {
          steps {
            sh 'checkov -d ./yelb-sidescan --use-enforcement-rules --prisma-api-url https://api.sg.prismacloud.io --bc-api-key $pcskey --repo-id jenkins-demo/code-sidescan-checking --branch main -o cli --quiet --compact'
          }
        }

        stage('') {
          steps {
            sh '''echo waiting for image creation.
sleep 10 mins'''
          }
        }

      }
    }

    stage('Scanning Images (UI Image)') {
      parallel {
        stage('Scanning Images (UI Image)') {
          steps {
            prismaCloudScanImage(image: 'harbor.alson.space/jenkins/yelb-ui:1.0', resultsFile: './yelb-ui-scan.json', logLevel: 'info', dockerAddress: 'unix:///var/run/docker.sock')
          }
        }

        stage('Scanning Images (App Image)') {
          steps {
            prismaCloudScanImage(image: 'harbor.alson.space/jenkins/yelb-appserver:1.0', resultsFile: './yelb-app-scan.json', logLevel: 'info', dockerAddress: 'unix:///var/run/docker.sock')
          }
        }

        stage('Scanning Images (DB Image)') {
          steps {
            prismaCloudScanImage(dockerAddress: 'unix:///var/run/docker.sock', image: 'harbor.alson.space/jenkins/yelb-db:1.0', resultsFile: './yelb-db-scan.json', logLevel: 'info')
          }
        }

      }
    }

    stage('Publish Scan Result') {
      steps {
        sh 'ls -tlr'
        prismaCloudPublish(resultsFilePattern: '*.json')
      }
    }

  }
  environment {
    pcskey = 'd505ece3-5ac5-4247-b1ff-b95ec4a28816::Sz52YQjmJDo0ESkK7x0n+E/EBZg='
  }
}