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
            sh 'if docker image inspect harbor.alson.space/jenkins/yelb-ui:1.0 >/dev/null 2>&1; then docker rmi harbor.alson.space/jenkins/yelb-ui:1.0; fi'
            sh 'if docker image inspect harbor.alson.space/jenkins/yelb-db:1.0 >/dev/null 2>&1; then docker rmi harbor.alson.space/jenkins/yelb-db:1.0; fi'
            sh 'if docker image inspect harbor.alson.space/jenkins/yelb-appserver:1.0 >/dev/null 2>&1; then docker rmi harbor.alson.space/jenkins/yelb-appserver:1.0; fi'
          }
        }

      }
    }

    stage('Code Scanning') {
      steps {
        sh 'checkov -d ./yelb-jenkins --use-enforcement-rules --prisma-api-url https://api.sg.prismacloud.io --bc-api-key $pcskey --repo-id yelb-jenkins/code-checking --branch main -o cli --quiet --compact'
      }
    }

    stage('Docker Image Building') {
      parallel {
        stage('Building UI app Image') {
          steps {
            sh 'docker build --no-cache ./yelb-jenkins/yelb-ui -t harbor.alson.space/jenkins/yelb-ui:1.0'
          }
        }

        stage('Building DB Image') {
          steps {
            sh 'docker build --no-cache ./yelb-jenkins/yelb-db -t harbor.alson.space/jenkins/yelb-db:1.0'
          }
        }

        stage('Building AppServer Image') {
          steps {
            sh 'docker build --no-cache ./yelb-jenkins/yelb-appserver -t harbor.alson.space/jenkins/yelb-appserver:1.0'
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
            prismaCloudScanImage(image: 'harbor.alson.space/jenkins/yelb-ui:1.0', resultsFile: './yelb-ui-01-scan.json', logLevel: 'info', dockerAddress: 'unix:///var/run/docker.sock')
          }
        }

        stage('Scanning Images (App Image)') {
          steps {
            prismaCloudScanImage(image: 'harbor.alson.space/jenkins/yelb-appserver:1.0', resultsFile: './yelb-app-01-scan.json', logLevel: 'info', dockerAddress: 'unix:///var/run/docker.sock')
          }
        }

        stage('Scanning Images (DB Image)') {
          steps {
            prismaCloudScanImage(dockerAddress: 'unix:///var/run/docker.sock', image: 'harbor.alson.space/jenkins/yelb-db:1.0', resultsFile: './yelb-db-01-scan.json', logLevel: 'info')
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
kubectl delete ns yelb-jenkins
kubectl create ns yelb-jenkins
kubectl apply -f ./yelb-jenkins/deployments/platformdeployment/Kubernetes/yaml/yelb-k8s-minikube-nodeport.yaml -n yelb-jenkins
kubectl get svc/yelb-ui -n yelb-jenkins'''
      }
    }

  }
  environment {
    pcskey = '1c788e25-83ba-4b31-94d6-3f99234e2e46::DdgP+op52pyjTlAF+nnpkXxt0i4='
  }
}
