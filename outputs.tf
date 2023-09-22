locals {
  eip_octects = split(".", aws_eip.web.public_ip)
}

output "instance_public_dns" {
  description = "EC2 instance public DNS"
  value       = "ec2-${local.eip_octects[0]}-${local.eip_octects[1]}-${local.eip_octects[2]}-${local.eip_octects[3]}.compute-1.amazonaws.com"
}

output "rds_address" {
  description = "Hostname of the RDS database"
  value       = try(aws_db_instance.primary[0].address, null)
}