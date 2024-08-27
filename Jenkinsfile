pipeline {
	agent any
	// tools {
	// 	node nodejs
	// }
	environment {
		IMAGE_NAME = 'playwright_python'
	}
	stages {
		stage('Checkout') {
			steps {
				git url: 'git@github.com:vanthiyadhevan/playwright_python.git', branch: 'main', credentialsId: 'vanthiyadhevan'
			}
		}
		stage ('Build Docker images') {
			steps {
				script {
					docker.build("${IMAGE_NAME}:${BUILD_NUMBER}", '.')
				}
			}
		}
		stage ('Test Your Application In Docker') {
			steps {
				sh "docker run ${IMAGE_NAME}:${BUILD_NUMBER} pytest -v"
			}
		}
	}
}