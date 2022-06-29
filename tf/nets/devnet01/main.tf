module "devnet" {
  source = "../../modules/devnet"

  deployment_name     = "devnet01"
  route53_zone_id     = "Z0313018249JD9NBSCJ1O" # dataavailability.link
  route53_domain_name = "devnet01.dataavailability.link"
  owner               = "jhilliard@polygon.technology"

}

