pipeline {
  agent any
  stages {
    stage('Source Code Scanning') {
      steps {
        sh '''pwd
checkov -d ./yelb-jenkins --use-enforcement-rules --prisma-api-url https://api.sg.prismacloud.io --bc-api-key $pcskey --repo-id jenkins-demo/code-checking --branch main -o cli -o junitxml --output-file-path console,CheckovReport.xml --quiet --compact
rm -Rf ./yelb-jenkins


'''
      }
    }

  }
  environment {
    pcskey = 'd505ece3-5ac5-4247-b1ff-b95ec4a28816::Sz52YQjmJDo0ESkK7x0n+E/EBZg='
  }
}