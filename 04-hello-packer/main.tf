provider "aws" {
    region = "us-east-1"
}

resource "aws_security_group" "web_sg" {
    name = "hello-terraform-packer-sg"
    ingress {
        from_port = 80
        to_port = 80
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

# Buscar nuestra ami más reciente creada con packer
data "aws_ami" "web_ami" {
    owners = ["self"]   # Pertenecen a mi cuenta
    filter {
        name = "name"
        values = ["my-ubuntu-*"]
    }
    most_recent = true
}

resource "aws_instance" "web" {
    instance_type = "t2.micro"
    # ami = "ami-07fb93ce44b4751f7"   # Obtenido luego de contruir con packer
    ami = data.aws_ami.web_ami.id   # Obtenido automáticamente nuestra imagen más reciente creada con packer
    tags = {
        Name = "Hello Terraform Packer"
    }
    vpc_security_group_ids = [
        aws_security_group.web_sg.id
    ]
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
