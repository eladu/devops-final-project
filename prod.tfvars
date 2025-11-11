# This file overrides variables in the root variables.tf for the 'prod' environment.
aws_region   = "us-east-1"
project_name = "Production-App"
# FIX: Using the correct variable name for production instance type
prod_instance_type = "t2.micro" 
# New VPC Name Override
vpc_name = "DevOps-Project-VPC"