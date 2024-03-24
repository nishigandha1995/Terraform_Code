# Define the AWS provider
provider "aws" {
  region = "us-east-1"  # Specify your desired region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"  # Specify your subnet CIDR block
  availability_zone       = "us-east-1a"  # Specify your desired availability zone
  map_public_ip_on_launch = true
}

# Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Create a route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create security group for Jenkins
resource "aws_security_group" "jenkins" {
  vpc_id = aws_vpc.main.id

  // Define security group rules as per your requirements
  // Example:
  // Allow inbound SSH and HTTP traffic for Jenkins
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group for web server
resource "aws_security_group" "web_server" {
  vpc_id = aws_vpc.main.id

  // Define security group rules as per your requirements
  // Example:
  // Allow inbound HTTP traffic for web server
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow inbound SSH traffic for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Jenkins EC2 instance
resource "aws_instance" "jenkins" {
  ami           = "ami-080e1f13689e07408"  # Specify your Ubuntu AMI ID
  instance_type = "t2.small"
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "jenkins-instance"
  }
}

# Launch web server EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-080e1f13689e07408"  # Specify your Ubuntu AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "web-server-instance"
  }
}
