pipeline {
	agent any
	tools {
		node nodejs
	}
	stages {
		stage('Checkout') {
			steps {
				git url: 'https://github.com/microsoft/playwright.git', branch: 'release-1.46'
			}
		}
		stage ('Build') {
			steps {
				sh 'npm install'
			}
		}
		stage ('Test') {
			steps {
				sh 'npm test'
			}
		}
		stage ('Build Docker images') {
			steps {
				script {
					docker.build("", '')
				}
			}
		}
	}
}