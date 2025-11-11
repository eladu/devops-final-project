# -----------------------------------------------------------------------------
# 0. Data Source: Get Latest Ubuntu AMI ID using SSM Parameter Store
# This is the most reliable way to find the latest supported AMI ID by AWS/Canonical.
# The path provided here is standard for Ubuntu 22.04 LTS AMIs.
# -----------------------------------------------------------------------------
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/jammy/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# -----------------------------------------------------------------------------
# 1. Core VPC
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
    Tier = "VPC"
  }
}

# -----------------------------------------------------------------------------
# 2. Internet Gateway (IGW)
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-IGW"
  }
}

# -----------------------------------------------------------------------------
# 3. Public Subnet & Route Table for IGW Access
# -----------------------------------------------------------------------------

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr
  map_public_ip_on_launch = true # EC2 in this subnet get public IPs

  tags = {
    Name = "${var.project_name}-Public-Subnet"
    Tier = "Public"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Default route points to the Internet Gateway (IGW)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-Public-RT"
  }
}

# Route Table Association (Public)
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# 4. Security Group for NAT Instance SSH Access
# -----------------------------------------------------------------------------
resource "aws_security_group" "nat_ssh_sg" {
  name        = "${var.project_name}-nat-ssh-sg"
  description = "Allow SSH from within the VPC"
  vpc_id      = aws_vpc.main.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound SSH only from the VPC's CIDR block
  ingress {
    description = "Allow SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.project_name}-NAT-SSH-SG"
  }
}

# -----------------------------------------------------------------------------
# 5. NAT Instance (Free Tier-compatible replacement for NAT Gateway)
# -----------------------------------------------------------------------------
resource "aws_instance" "nat_host" {
  # *** UPDATED TO USE SSM PARAMETER STORE VALUE ***
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value 
  instance_type          = "t2.micro" # Free Tier Eligible
  subnet_id              = aws_subnet.public.id
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.nat_ssh_sg.id]
  
  # CRITICAL: Must be disabled for the EC2 instance to forward traffic
  source_dest_check      = false 

  tags = {
    Name = "${var.project_name}-NAT-Instance"
    Tier = "Public"
  }
}

# -----------------------------------------------------------------------------
# 6. Private Subnet & Route Table for NAT Instance Access
# -----------------------------------------------------------------------------

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_cidr
  map_public_ip_on_launch = false # No public IPs

  tags = {
    Name = "${var.project_name}-Private-Subnet"
    Tier = "Private"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-Private-RT"
  }
}

# *** FINAL FIX: Explicitly define the route using aws_route ***
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  
  # ULTIMATE FIX: Target the NAT Instance's Primary Network Interface ID (ENI) 
  # instead of the Instance ID to resolve the dependency planning error.
  network_interface_id   = aws_instance.nat_host.primary_network_interface_id
  
  # The dependency is now implicit and the separate depends_on block is removed.
}

# Route Table Association (Private)
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}