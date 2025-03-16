terraform {
  required_providers {
    aws = {
      source            = "hashicorp/aws"
      version           = "~> 5.0"
    }
    docker = {
      source            = "kreuzwerker/docker"
      version           = "~> 3.0"
    }
  }
}

provider "aws" {
  region                = "us-east-2"
  endpoints {
    s3                  = "http://localhost:4566"
    sts                 = "http://localhost:4566"
    ec2                 = "http://localhost:4566"
  }
}

data "aws_vpc" "default" {
  default               = true
}

data "aws_subnets" "default" {
  filter {
    name                = "vpc-id"
    values              = [data.aws_vpc.default.id] 
  }
}

variable "scaling_ec2" {
  description           = "Configuracao de auto-scaling dos ec2."
  type                  = map(number)
  default               = {
    min_size = 2
    max_size = 10
  }
}

variable "server_port" {
  description           = "A porta que o servidor usará para solicitações HTTP"
  type                  = number
  default               = 8080
}

output "public_ip" {
  description           = "O endereço IP público do servidor web"
  value                 = aws_autoscaling_group.example.public_ip
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port           = var.server_port
    to_port             = var.server_port
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "exemplo" {
  launch_configuration  = aws_launch_configuration.example.name
  vpc_zone_identifier   = data.aws_subnets.default.ids 

  min_size              = var.scaling_ec2.min_size
  max_size              = var.scaling_ec2.max_size

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "example" {
  image_id              = "ami-0fb653ca2d3203ac1"
  instance_type         = "t2.micro"
  security_groups       = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Olá mundo!" > index.xhtml
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "ec2_simulada" {
  count               = var.scaling_ec2.min_size
  name                = "fake-ec2-instance"
  image               = "python:3.9-alpine"
  ports {
    internal          = var.server_port
    external          = var.server_port + count.index
  }

  entrypoint          = ["/bin/sh", "-c"]
  command = [
    "mkdir -p /www && echo 'Olá do container ${count.index}!' > /www/index.html && cd /www && python3 -m http.server 8080"
  ]
}