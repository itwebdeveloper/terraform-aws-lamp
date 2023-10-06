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

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
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