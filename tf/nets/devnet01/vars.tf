variable "deploy_name" {
  description = "The unique name for this particular deployment"
  type        = string
}

variable "owner" {
  description = "Name of devnet owner"
  type        = string
}

variable "subdomain" {
  description = "unique subdomain based on devnet deploy name"
  type        = string
}
