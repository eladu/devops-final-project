# The EC2 module accepts these variables from the root configuration.
variable "environment_name" {
  description = "The environment name (e.g., dev, stage, prod)."
  type        = string
}

variable "instance_count" {
  description = "The number of EC2 instances to launch."
  type        = number
}

variable "subnet_id" {
  description = "The target subnet ID where instances will be launched."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to launch."
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_name" {
  description = "The name of the existing AWS EC2 Key Pair for SSH access."
  type        = string
}