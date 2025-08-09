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
  profile = "terraform-tutorial"
}

resource "aws_default_vpc" "example" {
}

resource "aws_security_group" "example" {
  name = "allow-ssh"
  vpc_id = "${aws_default_vpc.example.id}"
  ingress {
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  from_port = 22
      to_port = 22
      protocol = "tcp"
    }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "example" {
  key_name   = "key"
  public_key = "${file("~/.ssh/terraform_tutorial.pub")}"
}

resource "aws_instance" "web" {
  ami = "ami-04a8220c151d8840a"
  instance_type = "t3.micro"
  key_name = aws_key_pair.example.key_name
  vpc_security_group_ids = [ aws_security_group.example.id ]
  tags = {
    Name = "terraform tutorial"
  }
}

resource "local_file" "hosts" {
  content = templatefile("../ansible/inventory.tmpl", {
    value = aws_instance.web.public_ip
  })
  filename = "../ansible/hosts"
}