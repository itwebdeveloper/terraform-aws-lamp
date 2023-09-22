variable "application_name" {
  description = "Application name"
  type = string
}

variable "application_slug" {
  description = "Dash-separated-lowercase application name"
  type = string
}

variable "application_owner" {
  description = "Full name of the owner of the application, useful for billing"
  type = string
}

variable "application_owner_email" {
  description = "Email of the owner of the application, useful for billing identification"
  type = string
}

variable "application_team" {
  description = "Team owning the application, useful for billing identification"
  type = string
}

variable "application_environment" {
  description = "Application environment"
  type = string

  validation {
    condition     = contains(["dev", "qa", "staging", "prod"], var.application_environment)
    error_message = "Valid values for application_environment are (dev, qa, staging, prod)."
  }
}

variable "ami_filter_name" {
  description = "Search string to match with the name of the AWS AMI"
  type = string
}

variable "ec2_instance_type" {
  description = "Type of the EC2 instance"
  type = string
  default = "t3.micro"
}

variable "key_pair_key_name" {
  description = "Name of the Key pair"
  type        = string
  default     = ""
}

variable "key_pair_public_key" {
  description = "Public key included in the Key pair"
  type        = string
  default     = ""
}

variable "ami" {
  description = "AMI used to create the AWS EC2 instance"
  type = string
  default     = ""
}

variable "eni_subnet_id" {
  description = "Subnet ID used by the network interface attached to the AWS EC2 instance"
  type = string
  default     = ""
}

variable "iam_instance_profile_name" {
  description = "Name of the instance profile attached to the AWS EC2 instance"
  type        = string
  default     = "CloudWatchAgentServerRole"
}

variable "has_load_balancer" {
  description = "Flag to set an Application Load Balancer (`true`) or not (`false`). Default `false`"
  type        = bool
  default     = false
}

variable "has_database" {
  description = "Flag to set a Database (`true`) or not (`false`). Default `false`"
  type        = bool
  default     = false
}

variable "database_password" {
  description = "Password of the RDS instance"
  type        = string
  default     = ""
}

variable "database_apply_changes_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default is `false`."
  type        = bool
  default     = false
}

variable "database_deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `true`."
  type        = bool
  default     = true
}