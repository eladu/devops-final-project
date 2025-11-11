# -----------------------------------------------------------------------------
# 1. Terraform Backend and Provider
# -----------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# 1.5 Remote State Data Source
# This allows 'dev' and 'stage' workspaces to read the network outputs 
# (like subnet IDs) that were created and stored in the 'prod' workspace state.
# -----------------------------------------------------------------------------
data "terraform_remote_state" "prod_network" {
  # This data source is only needed if we are NOT in the prod workspace
  count = terraform.workspace != "prod" ? 1 : 0
  
  backend = "local"
  config = {
    path = "terraform.tfstate.d/prod/terraform.tfstate"
  }
}


# -----------------------------------------------------------------------------
# 2. Local Configuration Map
# This map defines the configuration for each environment/workspace.
# -----------------------------------------------------------------------------
locals {
  config = {
    prod = {
      instance_count = 4
      instance_type  = var.prod_instance_type
      subnet_type    = "private"
    }
    stage = {
      instance_count = 3
      instance_type  = var.stage_instance_type
      subnet_type    = "public"
    }
    dev = {
      instance_count = 2
      instance_type  = var.dev_instance_type
      subnet_type    = "public"
    }
  }
}

# -----------------------------------------------------------------------------
# 3. Network Module Call (Conditionally Created)
# Provisions the VPC, Public/Private Subnets, IGW, and NAT Instance.
# We use 'count' to ensure this module is ONLY created in the 'prod' workspace.
# -----------------------------------------------------------------------------
module "network" {
  source = "./modules/network"

  # CRITICAL FIX: Only create the network module if the workspace is 'prod'.
  # This stops the creation of duplicate VPCs/NATs in 'dev' and 'stage'.
  count = terraform.workspace == "prod" ? 1 : 0
  
  # Inputs for the Network Module
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  public_cidr  = var.public_cidr
  private_cidr = var.private_cidr
  ec2_key_name = var.ec2_key_name
  
  # *** FIX: PASS THE NEW VARIABLE TO THE MODULE ***
  vpc_name = var.vpc_name
}

# -----------------------------------------------------------------------------
# 3.5 Local Variables for Safe Subnet ID Retrieval
# These locals safely retrieve the subnet IDs from either the local 'network' 
# module (if in 'prod') or the remote 'prod_network' state (if in 'dev'/'stage').
# -----------------------------------------------------------------------------
locals {
  public_subnet_id = try(
    module.network[0].public_subnet_id,             # Try to get from local network module (only exists in 'prod')
    data.terraform_remote_state.prod_network[0].outputs.public_subnet_id # Fallback to remote state
  )

  private_subnet_id = try(
    module.network[0].private_subnet_id,            # Try to get from local network module (only exists in 'prod')
    data.terraform_remote_state.prod_network[0].outputs.private_subnet_id # Fallback to remote state
  )
}

# -----------------------------------------------------------------------------
# 4. EC2 Module Calls (One block, controlled by for_each)
# -----------------------------------------------------------------------------
# This for loop iterates over the 'local.config' map (prod, stage, dev) 
# but uses the 'if' clause to filter the list: it only keeps the entry (k/v) 
# that matches the currently selected 'terraform.workspace'. 
# RESULT: This module runs exactly once for the active environment (e.g., only 'dev' if 'dev' is selected).
module "application_instances" {
  # This ensures the module only runs once per 'terraform workspace select'.
  for_each = { for k, v in local.config : k => v if k == terraform.workspace }

  source = "./modules/ec2"

  # The EC2 module receives the count and subnet ID based on the workspace logic above.
  environment_name = each.key
  instance_count   = each.value.instance_count
  instance_type    = each.value.instance_type
  ec2_key_name     = var.ec2_key_name

  # Conditional Subnet ID selection:
  subnet_id = each.value.subnet_type == "public" ? local.public_subnet_id : local.private_subnet_id
}