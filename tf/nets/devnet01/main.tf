provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      Environment    = "devnet"
      Network        = "avail"
      Owner          = var.owner
      DeploymentName = var.deployment_name
    }
  }
}

terraform {
  cloud {
    organization = "Polygon-Technology"
    workspaces {
      name = "gh-actions-demo"
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

  deployment_name     = "devnet01"
  route53_zone_id     = "Z0313018249JD9NBSCJ1O" # dataavailability.link
  route53_domain_name = "devnet01.dataavailability.link"
  owner               = "jhilliard@polygon.technology"

}
