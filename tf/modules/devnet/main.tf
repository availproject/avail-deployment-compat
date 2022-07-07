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

data "aws_caller_identity" "provisioner" {}

resource "aws_key_pair" "devnet" {
  key_name   = var.devnet_key_name
  public_key = var.devnet_key_value
}
