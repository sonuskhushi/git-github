provider "aws" {
    region     = "us-east-1"
    access_key = "AKIAT7SB3QSUSSEQODUM"
	secret_key = "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"
	
}

resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "pub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "pub"
  }
}

resource "aws_subnet" "priv" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "priv"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_eip" "ip" {
  vpc      = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.priv.id

  tags = {
    Name = "NGW"
  }

}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
  
  tags = {
    Name = "RT1"
  }

}


resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc.id

  route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.ngw.id
    }
  
  tags = {
    Name = "RT2"
  }

}

resource "aws_route_table_association" "as1" {
  subnet_id      = aws_subnet.pub.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "as2" {
  subnet_id      = aws_subnet.priv.id
  route_table_id = aws_route_table.rt2.id
}


resource "aws_security_group" "SG" {
  name        = "allow_web"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress{
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress{
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress{
      description      = "SSH"
      from_port        = 2
      to_port          = 2
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "SG"
  }
}


resource "aws_instance" "SSS" {
  ami           = "ami-02e136e904f3da870"
  instance_type = "t2.micro"

  tags = {
    Name = "SSS Server"
  }
}



	