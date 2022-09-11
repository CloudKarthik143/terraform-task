resource "aws_instance" "tomcat_server" {
  instance_type          = "t2.micro"
  ami                    = "ami-06489866022e12a14"
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]
  subnet_id              = aws_subnet.demo_public_subnet.id
  user_data              = file("user-data.sh")

  tags = {
    Name = "Tomcat server"
  }

}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "My VPC"
  }
}

resource "aws_subnet" "demo_public_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "My public subnet"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    "Name" = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.demo_public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "tomcat_sg" {
  name        = "tomcat-sg"
  description = "security group for tomcat server"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tomcat-sg"
  }
}