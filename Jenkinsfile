pipeline {
	agent any
	environment {
		IMAGE_NAME = 'playwright_python'
	}
	stages {
		stage('Checkout') {
			steps {
				// git url: 'git@github.com:vanthiyadhevan/playwright_python.git', branch: 'main', credentialsId: 'vanthiyadhevan'
				git url: 'https://github.com/vanthiyadhevan/playwright_python.git', branch: 'main'
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
