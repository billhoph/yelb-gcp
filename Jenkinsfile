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
        sh 'checkov -d ./yelb-jenkins --use-enforcement-rules --prisma-api-url https://api.sg.prismacloud.io --bc-api-key $pcskey --repo-id jenkins-demo/code-checking --branch main -o cli --quiet --compact'
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

    stage('Push Images to Harbor') {
      steps {
        sh '''docker login harbor.alson.space -u admin -p Harbor12345
docker push harbor.alson.space/jenkins/yelb-ui:1.0
docker push harbor.alson.space/jenkins/yelb-db:1.0
docker push harbor.alson.space/jenkins/yelb-appserver:1.0
'''
      }
    }

    stage('Deploy Application') {
      steps {
        sh '''kubectl cluster-info --context kind-demo
kubectl get pod -A
kubectl delete ns demo-app
kubectl create ns demo-app
kubectl apply -f ./yelb-jenkins/deployments/platformdeployment/Kubernetes/yaml/yelb-k8s-minikube-nodeport.yaml -n demo-app
kubectl get svc/yelb-ui -n demo-app'''
      }
    }

  }
  environment {
    pcskey = 'd505ece3-5ac5-4247-b1ff-b95ec4a28816::Sz52YQjmJDo0ESkK7x0n+E/EBZg='
  }
}