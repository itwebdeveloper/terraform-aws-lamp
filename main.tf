data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "availability-zone"
    values = [format("%s%s", data.aws_region.current.name,"a")]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_eip" "web" {
  instance             = aws_instance.web.id
  tags                 = {
    "App"   = "${var.application_name}"
    "Name"  = "${var.application_slug}-${var.application_environment}-elastic-ip-address"
    "Owner" = "${var.application_owner}"
    "Team"  = "${var.application_team}"
  }
  vpc                  = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "web" {
  description = "Security Group for ${var.application_name} web server"
  ingress     = var.ec2_security_group_ingress

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

  name        = "${var.application_slug}-${var.application_environment}-security-group"
  tags        = {
    "App"   = "${var.application_name}"
    "Name"  = "${var.application_slug}-${var.application_environment}-security-group"
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

resource "aws_network_interface" "web" {
  description        = "Primary network interface"
  subnet_id          = coalesce(var.eni_subnet_id, tolist((data.aws_subnet_ids.all.ids))[0])

  security_groups    = [
      aws_security_group.web.id,
  ]

  tags               = {
    "App"   = "${var.application_name}"
    "Name"  = "${var.application_slug}-${var.application_environment}-network-interface"
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
  }
}

resource "aws_instance" "web" {
  ami                                  = coalesce(var.ami, data.aws_ami.ubuntu.id)
  iam_instance_profile                 = var.iam_instance_profile_name
  instance_type                        = var.ec2_instance_type
  key_name                             = var.key_pair_key_name
  tags                                 = {
    "App"             = "${var.application_name}"
    "Environment"     = "${var.application_environment}"
    "Name"            = "${var.application_slug}-${var.application_environment}-web-1"
    "Owner"           = "${var.application_owner}"
    "Role"            = "Web server"
    "Team"            = "${var.application_team}"
  }

  root_block_device {
    tags                  = {
      "App"         = "${var.application_name}"
      "Environment" = "${var.application_environment}"
      "Name"        = "${var.application_slug}-${var.application_environment}-ebs"
      "Owner"       = "${var.application_owner}"
      "Team"        = "${var.application_team}"
    }
  }

  network_interface {
    delete_on_termination = false
    network_interface_id  = aws_network_interface.web.id
    device_index          = 0
  }

  lifecycle {
    ignore_changes = [
      ami,
      tags["Schedule"],
      tags["ScheduleMessage"],
      tags["Created by"],
      tags["Date created"],
      tags["Role Name"],
      tags["email"],
      root_block_device[0].tags["Created by"],
      root_block_device[0].tags["Date created"],
      root_block_device[0].tags["Role Name"],
      root_block_device[0].tags["email"]
    ]
  }
}

resource "aws_lb" "web" {
  count                      = var.has_load_balancer ? 1 : 0
  name                       = "${var.application_slug}-${var.application_environment}-lb"
  security_groups            = [
    aws_security_group.lb[0].id,
  ]
  subnets                    = [
    "subnet-09f1db6c",
    "subnet-fbdf63f7",
  ]
  tags                       = {
    "App"   = "${var.application_name}"
    "Name"  = "${var.application_slug}-${var.application_environment}-lb"
    "Owner" = "${var.application_owner}"
    "Team"  = "${var.application_team}"
  }
}

resource "aws_lb_listener" "http" {
  count             = var.has_load_balancer ? 1 : 0
  load_balancer_arn = aws_lb.web[0].arn
  port              = 80
  protocol          = "HTTP"
  tags              = {}

  default_action {
    target_group_arn = aws_lb_target_group.http[0].arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  count             = var.has_load_balancer ? 1 : 0
  load_balancer_arn = aws_lb.web[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:certificate/722f58cc-c176-4c76-8d7d-29f3ba97c5a2"
  tags              = {}

  default_action {
    target_group_arn = aws_lb_target_group.http[0].arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "http" {
  count             = var.has_load_balancer ? 1 : 0
  port              = 80
  protocol          = "HTTP"
  tags              = {
    "App"   = "${var.application_name}"
    "Name"  = "${var.application_slug}-${var.application_environment}-target-group"
    "Owner" = "${var.application_owner}"
    "Team"  = "${var.application_team}"
  }

  vpc_id            = data.aws_vpc.default.id
}

resource "aws_security_group" "lb" {
  count             = var.has_load_balancer ? 1 : 0
  description = "Security Group for the ${var.application_name} ${var.application_environment} Load Balancer"
  ingress     = [
    {
      cidr_blocks      = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 443
      ipv6_cidr_blocks = [
        "::/0",
      ]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks      = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = [
        "::/0",
      ]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
  ]
  name        = "${var.application_slug}-${var.application_environment}-load-balancer-security-group"
  tags        = {
    "App"   = "${var.application_name}"
    "Name"  = "${var.application_slug}-${var.application_environment}-load-balancer-security-group"
    "Owner" = "${var.application_owner}"
    "Team"  = "${var.application_team}"
  }
}