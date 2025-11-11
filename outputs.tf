
output "vpc_id" {
  description = "The ID of the main VPC. Only available in the 'prod' workspace."
  # Use module.network[0] to access the first (and only) instance of the module.
  # Use try() to return an empty string if the network module is not defined (count=0 in dev/stage).
  value = try(module.network[0].vpc_id, "")
}

output "public_subnet_id" {
  description = "The ID of the public subnet. Only available in the 'prod' workspace."
  value = try(module.network[0].public_subnet_id, "")
}

output "private_subnet_id" {
  description = "The ID of the private subnet. Only available in the 'prod' workspace."
  value = try(module.network[0].private_subnet_id, "")
}

output "dev_instance_ids" {
  description = "List of EC2 instance IDs for the dev environment."
  # The 'application_instances' module is correctly accessed using the map key.
  value = try(module.application_instances["dev"].instance_ids, [])
}

output "stage_instance_ids" {
  description = "List of EC2 instance IDs for the stage environment."
  value = try(module.application_instances["stage"].instance_ids, [])
}

output "prod_instance_ids" {
  description = "List of EC2 instance IDs for the prod environment."
  value = try(module.application_instances["prod"].instance_ids, [])
}