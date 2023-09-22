resource "aws_security_group" "db" {
  count             = var.has_database ? 1 : 0
  description = "Security Group for the ${var.application_name} database"
  ingress     = [
    {
      cidr_blocks      = []
      description      = "Allow MySQL connections from the ${var.application_name} ${var.application_environment} web server"
      from_port        = 3306
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [
          aws_security_group.web.id
      ]
      self             = false
      to_port          = 3306
    },
  ]

  egress = [
    {
      cidr_blocks      = [
          "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]

  name        = "${var.application_slug}-${var.application_environment}-database-security-group"
  tags        = {
    "App"   = "${var.application_name}"
    "Name"  = "${var.application_slug}-${var.application_environment}-database-security-group"
    "Owner" = "${var.application_owner}"
    "Team"  = "${var.application_team}"
  }

  lifecycle {
    ignore_changes = [
      tags["Created by"],
      tags["Date created"],
      tags["Role Name"],
      tags["email"]
    ]
    create_before_destroy = true
  }
}

resource "aws_db_instance" "primary" {
  count                                 = var.has_database ? 1 : 0
  allocated_storage                     = 20
  engine                                = "mysql"
  final_snapshot_identifier             = "${var.application_slug}-${var.application_environment}-database-final-snapshot"
  instance_class                        = "db.t2.micro"
  password                              = var.database_password
  tags                                  = {
    "App"   = "${var.application_name}"
    "Name"  = "${var.application_slug}-${var.application_environment}-database"
    "Owner" = "${var.application_owner}"
    "Team"  = "${var.application_team}"
  }
  username                              = "root"
  vpc_security_group_ids                = [
      aws_security_group.db[0].id,
  ]

  apply_immediately                     = var.database_apply_changes_immediately
  deletion_protection                   = var.database_deletion_protection
}