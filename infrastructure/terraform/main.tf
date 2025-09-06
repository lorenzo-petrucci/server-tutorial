terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
  profile = "server-tutorial"
}

resource "aws_default_vpc" "server-tutorial" {
}

resource "aws_security_group" "server-tutorial" {
  name = "server-tutorial-name"
  vpc_id = "${aws_default_vpc.server-tutorial.id}"
  ingress {
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "server-tutorial" {
  key_name   = "key"
  public_key = "${file("~/.ssh/server_tutorial.pub")}"
}

resource "aws_instance" "server-tutorial" {
  ami = "ami-04a8220c151d8840a"
  instance_type = "t3.micro"
  key_name = aws_key_pair.server-tutorial.key_name
  vpc_security_group_ids = [ aws_security_group.server-tutorial.id ]
  tags = {
    Name = "server tutorial"
  }
}

resource "local_file" "hosts" {
  content = templatefile("../ansible/inventory.tmpl", {
    value = aws_instance.server-tutorial.public_ip
  })
  filename = "../ansible/hosts"
}