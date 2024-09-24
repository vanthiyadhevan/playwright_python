provider "aws" {
  region = "us-east-1"
  # access_key = "<your_access_key>"
  # secret_key = "<your_secret_key>"
}

resource "aws_instance" "intro" {
  ami                    = "ami-0e86e20dae9224db8"
  instance_type          = "t2.micro"
  key_name               = "vanthiyadevan"
  vpc_security_group_ids = ["sg-0bff973659fc29440"]

  # Specify the root volume for the instance
  root_block_device {
    volume_size = 10    
    volume_type = "gp3" 
  }

  # User data to run scripts at instance launch
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    # Install Docker
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker

    # Add Jenkins user to Docker group
    sudo usermod -aG docker jenkins
    sudo chmod 666 /var/run/docker.sock

    # install Jave 
    apt install openjdk-17-jdk openjdk-17-jre -y

  EOF

  tags = {
    Name = "jenkins-slave"
  }
}

# Outputs for Public and Private IP addresses
output "PublicIP" {
  value = aws_instance.intro.public_ip
}

output "PrivateIP" {
  value = aws_instance.intro.private_ip
}
