# The network module accepts these variables from the root configuration.
variable "project_name" {
  description = "Project name tag."
  type        = string
}

variable "vpc_name" {
  description = "VPC name."
  type = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
}

variable "private_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
}

variable "ec2_key_name" {
  description = "The name of the existing AWS EC2 Key Pair for SSH access."
  type        = string
}
