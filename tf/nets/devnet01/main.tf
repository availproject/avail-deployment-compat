provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      Environment    = "devnet"
      Network        = "avail"
      Owner          = var.owner
      DeploymentName = var.deploy_name
    }
  }
}

terraform {
  cloud {
    organization = "Polygon-Technology"
    workspaces {
      name = "awx_devnet_avail"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19.0"
    }
  }

  required_version = ">= 1.2.0"
}

module "devnet" {
  source = "../../modules/devnet"
  deployment_name     = var.deploy_name
  route53_zone_id     = "Z0491767NTM9F1P94D5W" # devnet-polygon.com
  route53_domain_name = "${var.deploy_name}.devnet-polygon.com"
  owner               = var.owner
}

resource "aws_route53_zone" "my_hosted_zone" {
  name = var.domain_name
}
