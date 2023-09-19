provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

module "aws_lamp_simple_app" {
  source = "./modules/terraform-aws-lamp"
  version = "0.1.1"

  application_name              = "My simple app"
  application_slug              = "my-simple-app"
  application_owner             = var.application_owner
  application_owner_email       = var.application_owner_email
  application_environment       = "dev"
  application_team              = "Engineering"
  ami_filter_name               = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  key_pair_key_name             = var.key_pair_key_name
  key_pair_public_key           = var.key_pair_public_key
}
