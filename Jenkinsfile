pipeline {
    agent any

    environment {
        TF_DIR = './terraform'                // Path to your Terraform files
        SSH_USER = 'ec2-user'                 // User to SSH into EC2
        SSH_KEY = 'your-ssh-key-path'         // Path to your SSH private key
        NODE_LABEL = 'jenkins-slave'          // Label to identify the slave node
    }

    stages {
        stage('Provision Infrastructure with Terraform') {
            steps {
                dir(TF_DIR) {
                    script {
                        // Initialize and apply Terraform to create the EC2 instance
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Get EC2 Instance IP') {
            steps {
                dir(TF_DIR) {
                    script {
                        // Get the EC2 instance public IP
                        EC2_IP = sh(script: "terraform output -raw Public_IP", returnStdout: true).trim()
                        echo "EC2 Instance IP: ${EC2_IP}"
                    }
                }
            }
        }

        stage('Configure Jenkins Slave (Agent)') {
            steps {
                script {
                    // Dynamically configure the EC2 instance as a Jenkins agent via SSH
                    def slaveNode = EC2_IP
                    def jenkinsUser = 'jenkins'   // The user that Jenkins will use to run jobs on the agent

                    // SSH into the EC2 instance to install Java and prepare for Jenkins connection
                    sh """
                    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${SSH_USER}@${EC2_IP} << 'EOF'
                    sudo yum update -y
                    sudo amazon-linux-extras install java-openjdk11 -y
                    sudo service docker start
                    EOF
                    """

                    // Connect the EC2 instance as a Jenkins slave (agent) using the SSH agent plugin
                    node {
                        jenkins.model.Jenkins.getInstance().addNode(new hudson.slaves.DumbSlave(
                            "jenkins-slave",  // Node name
                            "Slave node for Jenkins",  // Description
                            "/home/${jenkinsUser}",  // Remote FS root
                            "1",  // Number of executors
                            hudson.model.Node.Mode.NORMAL,  // Mode
                            NODE_LABEL,  // Label
                            new hudson.plugins.sshslaves.SSHLauncher(
                                slaveNode,  // Host
                                22,  // Port
                                "your-ssh-credentials-id"  // Jenkins credentials ID
                            ),
                            new hudson.slaves.RetentionStrategy.Always()
                        ))
                    }
                }
            }
        }

        stage('Build Docker Image on Jenkins Slave') {
            agent { label NODE_LABEL }  // Ensure this stage runs on the Jenkins slave

            steps {
                script {
                    // Assuming Dockerfile is in the repository or available on the instance
                    sh """
                    docker build -t your-image-name .
                    docker run -d --name your-container-name your-image-name
                    """
                }
            }
        }

        stage('Cleanup (Optional)') {
            steps {
                script {
                    // Destroy the infrastructure after the build
                    dir(TF_DIR) {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }
}
