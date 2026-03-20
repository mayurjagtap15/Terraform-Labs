provider "aws" {
  region     = "us-east-2"
  access_key = "AKIAWFY4T6PQIHMGGMWF"
  secret_key = "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"
} 


# ---------------- VPC ----------------
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-lab-vpc"
  }
}

# ---------------- Subnet ----------------
resource "aws_subnet" "lab_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-lab-subnet"
  }
}

# ---------------- Internet Gateway ----------------
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "terraform-lab-igw"
  }
}

# ---------------- Route Table ----------------
resource "aws_route_table" "lab_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = "terraform-lab-rt"
  }
}

resource "aws_route_table_association" "lab_rta" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_rt.id
}

# ---------------- Security Group ----------------
resource "aws_security_group" "lab_sg" {
  name        = "terraform-lab-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP in production
  }

  ingress {
    description = "HTTP"
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
    Name = "terraform-lab-sg"
  }
}

# ---------------- EC2 Instance ----------------
resource "aws_instance" "ec2_example" {
  ami                    = "ami-07062e2a343acc423"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.lab_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl start apache2
              systemctl enable apache2
              chown -R ubuntu:ubuntu /var/www/html
              echo "<html><body><h1>Hello this custom page built with Terraform User Data</h1></body></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "Terraform-Lab-EC2"
  }
}
