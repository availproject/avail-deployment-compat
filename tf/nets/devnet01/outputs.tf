output "full_node_ips" {
  value = "${module.devnet.ec2_full_node_ips}"
}

output "validator_ips" {
  value = "${module.devnet.ec2_validator_ips}"
}

output "explorer_ips" {
  value = "${module.devnet.ec2_explorer_ips}"
}

output "light_client_ips" {
  value = "${module.devnet.ec2_light_client_ips}"
}
