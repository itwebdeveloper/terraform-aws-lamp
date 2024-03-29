data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "availability-zone"
    values = [format("%s%s", data.aws_region.current.name, "a")]
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  tags = local.elastic_ip_tags
  vpc = true

  lifecycle {
    prevent_destroy = true
  }
}