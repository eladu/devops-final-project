# The region where all resources will be provisioned
variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

# A common prefix for resource naming
variable "project_name" {
  description = "Name of the project used for tagging and resource naming."
  type        = string
  default     = "Terraform-Project"
}

# --- NEW VPC NAME VARIABLE ---
variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
  default     = "DevOps-Project-VPC"
}

# VPC and Subnet CIDR blocks
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

# --- ENVIRONMENT-SPECIFIC INSTANCE TYPES ---

variable "dev_instance_type" {
  description = "The EC2 instance type for the dev environment."
  type        = string
  default     = "t2.micro"
}

variable "stage_instance_type" {
  description = "The EC2 instance type for the stage environment."
  type        = string
  default     = "t2.small" # Defaulting here, can be overridden in stage.tfvars
}

variable "prod_instance_type" {
  description = "The EC2 instance type for the prod environment."
  type        = string
  default     = "t2.medium" # Defaulting here, can be overridden in prod.tfvars
}

# --- SSH Key Name ---
variable "ec2_key_name" {
  description = "The name of the existing AWS EC2 Key Pair for SSH access."
  type        = string
  # !!! CHANGE 'my-ssh-key' to the ACTUAL name of your key pair in AWS !!!
  default     = "devopsproj-useast1-key" 
}