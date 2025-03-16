terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-2"
  endpoints {
    s3 = "http://localhost:4566"
    sts = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }
}

variable "server_port" {
  description = "A porta que o servidor usará para solicitações HTTP"
  type = number
  default = 8080
}

output "public_ip" {
  description = "O endereço IP público do servidor web"
  value = aws_instance.example.public_ip
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Olá mundo!" > index.xhtml
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }
}

resource "docker_container" "ec2_simulada" {
  name  = "fake-ec2-instance"
  image = "python:3.9-alpine"
  ports {
    internal = var.server_port
    external = var.server_port
  }

  entrypoint = ["/bin/sh", "-c"]
  command = [
    "mkdir -p /www && echo 'Olá mundo!' > /www/index.html && cd /www && python3 -m http.server ${var.server_port}"
  ]
}