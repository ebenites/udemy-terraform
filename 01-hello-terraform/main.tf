provider "aws" {
    region = "us-east-1"
    version = "~> 3.22"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "web" {
    instance_type = "t2.micro"
    ami = "ami-0be2609ba883822ec"
    tags = {
        Name = "Hello Terraform"
    }
    vpc_security_group_ids = [
        aws_security_group.web_sg.id
    ]
    user_data = <<-EOF
    #!/bin/bash
    sudo amazon-linux-extras install nginx1.12 -y
    sudo service nginx start
    EOF
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "web_sg" {
    name = "hello-terraform-sg"
    ingress {
        from_port = 80  # Desde que puerto inicia nuestro rango
        to_port = 80    # Hasta que puerto termina nuestro rango
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# https://www.terraform.io/docs/configuration/outputs.html
output "public_ip" {
  value = aws_instance.web.public_ip
}

# Fuente: https://gist.github.com/jjruescas/4edef47d26b7828d2b0263291af0f7cd
# Nginx on EC2: https://docs.nginx.com/nginx/deployment-guides/amazon-web-services/ec2-instances-for-nginx/