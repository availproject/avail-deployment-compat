variable "region" {
  description = "The region where we want to deploy"
  type        = string
  default     = ""
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
variable "validator_count" {
  description = "The number of validators that we're going to deploy"
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
