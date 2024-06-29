terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "us-east-2"
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "myVPC"
    }
}

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.0.0/20"
    availability_zone = "us-east-2a"
    tags = {
      Name = "mysubnet1"
    }
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.16.0/20"
    availability_zone = "us-east-2b"
    tags = {
      Name = "mysubnet2"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "igw"
    }
}

resource "aws_route_table" "myroute" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "MyRouteTable"
    }
}

resource "aws_route" "myroute2" {
    route_table_id = aws_route_table.myroute.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  
}

resource "aws_security_group" "mysg" {
    name = "security_group"
    description = "Allow ssh"

ingress {
    from_port = 22
    to_port = 22
    protocol =  "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }   
}

# create an instance
resource "aws_instance" "myec2" {
    ami = "ami-09040d770ffe2224f"
    instance_type = "t2.micro"
    key_name = "main-key"
    security_groups = [aws_security_group.mysg.name]
    count = 5
    tags = {
        Name = "myEC2"
    }
}