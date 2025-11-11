# The EC2 module outputs these values back to the root configuration.
output "instance_ids" {
  description = "List of IDs of the provisioned EC2 instances."
  value       = aws_instance.app_server.*.id
}