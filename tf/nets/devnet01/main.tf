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

module "{module_name}" {
  source              = "../../modules/devnet"
  deployment_name     = var.deploy_name
  route53_zone_id     = "Z0313018249JD9NBSCJ1O" # dataavailability.link
  route53_domain_name = "${var.deploy_name}.dataavailability.link"
  owner               = var.owner
  devnet_key_name     = "ansiblePair"
  full_node_count     = var.full_node_count
  validator_count     = var.validator_count
  light_client_count  = var.lightclient_count
  explorer_count      = var.explorer_count
}
