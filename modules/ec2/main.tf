# -----------------------------------------------------------------------------
# Data Source: Find latest Ubuntu AMI
# -----------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical AWS account ID
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------
resource "aws_security_group" "ssh_access" {
  name_prefix = "${var.environment_name}-ssh-sg-"
  description = "Allow SSH inbound traffic from anywhere"
  vpc_id      = data.aws_vpc.selected.id # Dynamically look up VPC ID via subnet

  # Inbound SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment_name}-SSH-SG"
    Environment = var.environment_name
  }
}

# -----------------------------------------------------------------------------
# EC2 Instance Provisioning
# -----------------------------------------------------------------------------
resource "aws_instance" "app_server" {
  count         = var.instance_count # Controlled by the root configuration (.tfvars)
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  # Assign public IP only if the subnet is public (Terraform handles this implicitly)
  associate_public_ip_address = data.aws_subnet.selected.map_public_ip_on_launch
  
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name        = "${var.environment_name}-AppServer-${count.index + 1}"
    Environment = var.environment_name
  }
}

# -----------------------------------------------------------------------------
# Data Sources for Dynamic Lookups
# -----------------------------------------------------------------------------

# Lookup Subnet Details (needed to determine public IP assignment)
data "aws_subnet" "selected" {
  id = var.subnet_id
}

# Lookup VPC ID (needed for Security Group creation)
data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}