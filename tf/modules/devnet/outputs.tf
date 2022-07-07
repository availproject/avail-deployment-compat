
output "ec2_full_node_ips" {
  value = "${aws_instance.full_node.*.private_ip}"
}
output "ec2_validator_ips" {
  value = "${aws_instance.validator.*.private_ip}"
}
output "ec2_explorer_ips" {
  value = "${aws_instance.explorer.*.private_ip}"
}
output "ec2_light_client_ips" {
  value = "${aws_instance.light_client.*.private_ip}"
}

output "alb_domain_name" {
  value = aws_lb.avail_nodes.dns_name
}
