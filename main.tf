data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

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

resource "aws_security_group" "web" {
  description = "Security Group for ${var.application_name} web server"
  ingress     = var.has_load_balancer ? [
    {
      cidr_blocks = []
      description = "Allow HTTP connections from the Load Balancer"
      from_port   = 80
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol        = "tcp"
      security_groups = [
        aws_security_group.lb[0].id,
      ]
      self            = false
      to_port         = 80
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
  ] : [
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

  egress = [
    {
      cidr_blocks = [
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

  name = "${var.application_slug}-${var.application_environment}-security-group"
  tags = local.ec2_instance_security_group_tags

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
  description = "Primary network interface"
  subnet_id   = coalesce(var.eni_subnet_id, tolist((data.aws_subnet_ids.all.ids))[0])

  security_groups = [
    aws_security_group.web.id,
  ]

  tags = local.network_interface_tags

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
  ami                  = coalesce(var.ami, data.aws_ami.ubuntu.id)
  iam_instance_profile = var.iam_instance_profile_name
  instance_type        = var.ec2_instance_type
  key_name             = var.key_pair_key_name
  tags                 = local.ec2_instance_tags

  root_block_device {
    volume_size = var.ebs_size
    tags        = local.ebs_volume_tags
  }

  network_interface {
    delete_on_termination = false
    network_interface_id  = aws_network_interface.web.id
    device_index          = 0
  }

  lifecycle {
    ignore_changes = [
      ami,
      root_block_device[0].tags["Created by"],
      root_block_device[0].tags["Date created"],
      root_block_device[0].tags["Role Name"],
      root_block_device[0].tags["email"],
      tags["Schedule"],
      tags["ScheduleMessage"],
      tags["Created by"],
      tags["Date created"],
      tags["Role Name"],
      tags["email"]
    ]
  }
}

resource "aws_lb" "web" {
  count = var.has_load_balancer ? 1 : 0
  name  = "${var.application_slug}-${var.application_environment}-lb"
  security_groups = [
    aws_security_group.lb[0].id,
  ]
  subnets = [
    "subnet-09f1db6c",
    "subnet-fbdf63f7",
  ]
  tags = local.load_balancer_tags
}

resource "aws_lb_listener" "http" {
  count             = var.has_load_balancer ? 1 : 0
  load_balancer_arn = aws_lb.web[0].arn
  port              = 80
  protocol          = "HTTP"
  tags              = local.load_balancer_http_listener_tags

  default_action {
    target_group_arn = aws_lb_target_group.http[0].arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  count             = var.has_load_balancer && var.has_load_balancer_https_listener ? 1 : 0
  load_balancer_arn = aws_lb.web[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.ssl_certificate_arn
  tags              = local.load_balancer_https_listener_tags

  default_action {
    target_group_arn = aws_lb_target_group.http[0].arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "http" {
  count    = var.has_load_balancer ? 1 : 0
  port     = 80
  protocol = "HTTP"
  tags = local.load_balancer_target_group_tags

  vpc_id = data.aws_vpc.default.id

  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group_attachment" "http" {
  count    = var.has_load_balancer ? 1 : 0
  target_group_arn = aws_lb_target_group.http[0].arn
  target_id        = aws_instance.web.id
  port             = 80
}

resource "aws_security_group" "lb" {
  count       = var.has_load_balancer ? 1 : 0
  description = "Security Group for the ${var.application_name} ${var.application_environment} Load Balancer"
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = ""
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
      description = ""
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
  ]

  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    }
  ]

  name = "${var.application_slug}-${var.application_environment}-load-balancer-security-group"
  tags = local.load_balancer_security_group_tags
}