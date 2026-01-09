terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "say_hello" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    docker run aidencullo/say_hello
  EOF
  )

  tags = {
    Name = "say-hello"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

output "instance_id" {
  value = aws_instance.say_hello.id
}

output "public_ip" {
  value = aws_instance.say_hello.public_ip
}
