variable "deployment_name" {
  description = "The unique name for this particular deployment"
  type        = string
}
variable "route53_zone_id" {
  description = "The ID of the hosted zone to contain the CNAME record to our LB"
  type        = string
}
variable "route53_domain_name" {
  description = "Our base domain"
  type        = string
}
variable "owner" {
  description = "The main point of contact for this particular deployment"
  type        = string
}

variable "region" {
  description = "The region where we want to deploy"
  type        = string
  default     = "us-west-2"
}
variable "zones" {
  description = "The zones for deployment"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
variable "base_ami" {
  description = "Value of the base AMI that we're using"
  type        = string
  default     = "ami-0d70546e43a941d70"
}
variable "base_instance_type" {
  description = "The type of instance that we're going to use"
  type        = string
  default     = "t2.micro"
}
variable "full_node_count" {
  description = "The number of full nodes that we're going to deploy"
  type        = number
  default     = 6
}
variable "light_client_count" {
  description = "The number of light clients that we're going to deploy"
  type        = number
  default     = 3
}
variable "validator_count" {
  description = "The number of validators that we're going to deploy"
  type        = number
  default     = 3
}
variable "explorer_count" {
  description = "The number of explorers that we're going to deploy"
  type        = number
  default     = 3
}
variable "devnet_key_name" {
  description = "The name that we want to use for the ssh key pair"
  type        = string
  default     = "2022-06-21-avail-devnet"
}
variable "devnet_key_value" {
  description = "The public key value to use for the ssh key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK15+JgUSPwfeuoZRe17ygPPnby/Fh+O4ffpwOgBBcNc avail@polygon.technology"
}
variable "devnet_public_subnet" {
  description = "The cidr block for the public subnet in our VPC"
  type        = list(string)
  default     = ["10.0.2.0/23", "10.0.4.0/23", "10.0.6.0/23"]
}
variable "devnet_private_subnet" {
  description = "The cidr block for the private subnet in our VPC"
  type        = list(string)
  default     = ["10.0.128.0/23", "10.0.130.0/23", "10.0.132.0/23"]
}
variable "devnet_vpc_block" {
  description = "The cidr block for our VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "avail_rpc_port" {
  default     = 9933
  description = "The RPC Port that Avail is listening on"
  type        = number
}
variable "avail_ws_port" {
  default     = 9944
  description = "The WS Port that Avail is listening on"
  type        = number
}
variable "avail_explorer_port" {
  default     = 8080
  description = "The HTTP port that the explorer is listening on"
  type        = number
}