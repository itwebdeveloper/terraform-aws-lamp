output "instance_public_dns" {
  description = "EC2 instance public DNS"
  value       = "ec2-${split(".", aws_eip.web.public_ip)[0]}-${split(".", aws_eip.web.public_ip)[1]}-${split(".", aws_eip.web.public_ip)[2]}-${split(".", aws_eip.web.public_ip)[3]}.compute-1.amazonaws.com"
}

output "rds_address" {
  description = "Hostname of the RDS database"
  value       = try(aws_db_instance.primary[0].address, null)
}