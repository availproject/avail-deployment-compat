terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      Environment = "devnet"
      Network     = "avail"
      Owner       = "jhilliard@polygon.technology"
      # this won't work in all cases, but for arbitrary devnets that are being created it should be fine
      Lineage = jsondecode(file("terraform.tfstate")).lineage
    }
  }
}

resource "aws_ssm_parameter" "lineage" {
  name  = "terraform-lineage"
  type  = "String"
  value = jsondecode(file("terraform.tfstate")).lineage
}

data "aws_caller_identity" "provisioner" {}

resource "aws_key_pair" "devnet" {
  key_name   = var.devnet_key_name
  public_key = var.devnet_key_value
}






output "ec2_full_node_ips" {
  value = ["${aws_instance.full_node.*.private_ip}"]
}
output "ec2_validator_ips" {
  value = ["${aws_instance.validator.*.private_ip}"]
}
output "ec2_explorer_ips" {
  value = ["${aws_instance.explorer.*.private_ip}"]
}

output "alb_domain_name" {
  value = aws_lb.avail_nodes.dns_name
}
