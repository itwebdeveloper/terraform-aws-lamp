output "instance_public_dns" {
  description = "EC2 instance public DNS"
  value       = aws_instance.web.public_dns
}

output "rds_address" {
  description = "Hostname of the RDS database"
  value       = aws_db_instance.primary[0].address
}