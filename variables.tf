variable "application_name" {
  description = "Application name"
  type        = string
}

variable "application_slug" {
  description = "Dash-separated-lowercase application name"
  type        = string
}

variable "application_owner" {
  description = "Full name of the owner of the application, useful for billing"
  type        = string
}

variable "application_owner_email" {
  description = "Email of the owner of the application, useful for billing identification"
  type        = string
}

variable "application_team" {
  description = "Team owning the application, useful for billing identification"
  type        = string
}

variable "application_environment" {
  description = "Application environment"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "staging", "prod"], var.application_environment)
    error_message = "Valid values for application_environment are (dev, qa, staging, prod)."
  }
}

variable "ami_filter_name" {
  description = "Search string to match with the name of the AWS AMI"
  type        = string
}

variable "ec2_instance_type" {
  description = "Type of the EC2 instance"
  type        = string
  default     = "t3.micro"
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
  type        = string
  default     = ""
}

variable "eni_subnet_id" {
  description = "Subnet ID used by the network interface attached to the AWS EC2 instance"
  type        = string
  default     = ""
}

variable "iam_instance_profile_name" {
  description = "Name of the instance profile attached to the AWS EC2 instance"
  type        = string
  default     = "CloudWatchAgentServerRole"
}

variable "ec2_security_group_ingress" {
  description = "Ingress rules for the EC2 instance security group"
  type        = list(any)
  default = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = "Allow HTTP connections from everywhere"
      from_port   = 80
      ipv6_cidr_blocks = [
        "::/0",
      ]
      prefix_list_ids = []
      protocol        = "tcp"
      security_groups = []
      self            = false
      to_port         = 80
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = "Allow HTTPS connections from everywhere"
      from_port   = 443
      ipv6_cidr_blocks = [
        "::/0",
      ]
      prefix_list_ids = []
      protocol        = "tcp"
      security_groups = []
      self            = false
      to_port         = 443
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "SSH connections from everywhere"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
  ]
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

locals {
  cloudwatch_alarms_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-cloudwatch-alarm"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }

  ec2_instance_security_group_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-security-group"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }

  ec2_instance_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-web-1"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }

  ebs_volume_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-ebs"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }

  elastic_ip_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-elastic-ip-address"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }

  network_interface_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-network-interface"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }

  load_balancer_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-load-balancer"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }

  load_balancer_http_listener_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-load-balancer-http-listener"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }

  load_balancer_https_listener_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-load-balancer-https-listener"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }

  load_balancer_target_group_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-load-balancer-target-group"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }

  load_balancer_security_group_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-load-balancer-security-group"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }


  rds_instance_security_group_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-database-security-group"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "DB"
    Team        = var.application_team
  }

  rds_instance_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-database"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "DB"
    Team        = var.application_team
  }

  sns_topic_tags = {
    App         = var.application_name
    Environment = var.application_environment
    Name        = "${var.application_slug}-${var.application_environment}-sns-topic"
    Owner       = var.application_owner
    Project     = var.application_name
    Role        = "Web"
    Team        = var.application_team
  }
}