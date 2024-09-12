def COLOR_MAP = [
    'SUCCESS' : 'good',
    'FAILURE' : 'danger',
    'UNSTABLE' : 'warning',
    'ABOURTED' : 'warning'
]
pipeline {
    agent any

    environment {
        // TF_DIR = './'                // Path to your Terraform files
        SSH_USER = 'ubuntu'                 // User to SSH into EC2
        SSH_KEY = '/home/mr-skyline/Downloads/'         // Path to your SSH private key
        NODE_LABEL = 'jenkins-slave'          // Label to identify the slave node


        IMAGE_NAME = 'playwright'
    }

    stages {
        stage ('Checkout') {
            steps {
                git url: 'https://github.com/vanthiyadhevan/playwright_python.git', branch: 'jenkins_slave_node'
            }
        }
        stage('Provision Infrastructure with Terraform') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY', credentialsId: 'aws_creds']]) 
                    {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Get EC2 Instance IP') {
            steps {
                script {
                    // Get the EC2 instance public IP
                    EC2_IP = sh(script: "terraform output -raw PublicIP", returnStdout: true).trim()
                    echo "EC2 Instance IP: ${EC2_IP}"
                }
            }
        }

        stage('Configure Jenkins Slave (Agent)') {
            steps {
                script {
                    // Dynamically configure the EC2 instance as a Jenkins agent via SSH
                    def slaveNode = EC2_IP
                    def jenkinsUser = 'ubuntu'   // The user that Jenkins will use to run jobs on the agent
                    def nodeName = "jenkins-slave"
                    def remoteFS = "/home/${jenkinsUser}"
                    def credentialsId = "slave_node"
                    def nodeDescription = "Slave node for Jenkins"
                    def numberOfExecutors = "1"
                    def mode = hudson.model.Node.Mode.NORMAL
                    def label = NODE_LABEL
                    def sshPort = 22

                    // Check if the node already exists to avoid duplication
                    def existingNode = jenkins.model.Jenkins.getInstance().getNode(nodeName)
                    if (existingNode != null) {
                        println "Node '${nodeName}' already exists. Skipping creation."
                    } else {
                        // Create the node and add it to Jenkins
                        def slave = new hudson.slaves.DumbSlave(
                            nodeName,  // Node name
                            nodeDescription,  // Description
                            remoteFS,  // Remote FS root
                            numberOfExecutors,  // Number of executors
                            mode,  // Mode (NORMAL/EXCLUSIVE)
                            label,  // Label
                            new hudson.plugins.sshslaves.SSHLauncher(
                                slaveNode,  // Host
                                sshPort,  // Port
                                credentialsId  // Jenkins credentials ID for SSH
                            ),
                            new hudson.slaves.RetentionStrategy.Always()  // Retention strategy
                        )
                        jenkins.model.Jenkins.getInstance().addNode(slave)
                        println "Node '${nodeName}' added successfully."
                    }
                }
            }
    }

        stage('Build Docker Image on Jenkins Slave') {
            agent { label NODE_LABEL }  // Ensure this stage runs on the Jenkins slave

            steps {
                script {
                    // Assuming Dockerfile is in the repository or available on the instance
                    docker.build("${IMAGE_NAME}:${BUILD_NUMBER}", '.')
                }
            }
        }
        stage('Run the docker image') {
            agent {label NODE_LABEL}
            steps {
                sh "docker run ${IMAGE_NAME}:${BUILD_NUMBER} pytest -v"
            }
        }
    }
    post {
        always {
            echo "slack Notification..."
            slackSend channel: "#jenkins-cicd",
            color: COLOR_MAP[currentBuild.currentResult],
            message: "*${currentBuild.currentResult}:* job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}
