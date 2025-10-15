resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr
    tags = {
      Name = "my-vpc"
      env = var.env
    }
  
}
resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      Name = "my-igw"
      env = var.env
    }
  
}
data "aws_availability_zones" "region_zones" {
  state = "available"
}
resource "aws_subnet" "public-subnet" {
    cidr_block = var.public_subnet_cidr
    vpc_id = aws_vpc.my-vpc.id
    availability_zone = data.aws_availability_zones.region_zones.names[0]
    tags = {
      Name = "public-subnet"
      env = var.env
    }
  
}
resource "aws_subnet" "private-subnet" {
    cidr_block = var.private_subnet_cidr
    vpc_id = aws_vpc.my-vpc.id
    availability_zone = data.aws_availability_zones.region_zones.names[1]
    tags = {
      Name = "private-subnet"
      env = var.env
    }
  
}
resource "aws_route_table" "my-rt" {
    vpc_id = aws_vpc.my-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw.id
    }
    tags = {
      name = "public_route_table"
      env = var.env
    }
  
}
resource "aws_route_table_association" "public-route" {
    route_table_id = aws_route_table.my-rt.id
    subnet_id = aws_subnet.public-subnet.id
  
}
resource "aws_security_group" "my-sg" {
    vpc_id = aws_vpc.my-vpc.id
    dynamic "ingress" {
        for_each = var.sg_ports
        content {
          from_port = ingress.value
          to_port = ingress.value
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "instance-sg"
      env = var.env
    }
  
}
resource "aws_key_pair" "my-key" {
    key_name = "my-key"
    public_key = file("./my-key.pub")
    tags = {
      Name = "my-key"
      env = var.env
    }
  
}
resource "aws_instance" "public-instance" {
    key_name = aws_key_pair.my-key.key_name
    ami = var.ami
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public-subnet.id
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    associate_public_ip_address = true
    user_data = file("file.txt")
    tags = {
      Name = "public-instance"
      env = var.env
    }
}
resource "aws_dynamodb_table" "my-db" {
    name = var.dynamodb_details.name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = var.dynamodb_details.hash_key
    attribute {
      name = var.dynamodb_details.hash_key
      type = var.dynamodb_details.type
    }
    tags = {
      name = var.dynamodb_details.name
      env = var.env
    }
  
}
