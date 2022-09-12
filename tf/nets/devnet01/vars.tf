variable "deploy_name" {
  description = "The unique name for this particular deployment"
  type        = string
}

variable "owner" {
  description = "Name of devnet owner"
  type        = string
}

variable "full_node_count" {
  description = "number of full nodes in devnet"
  type        = number
}

variable "validator_count" {
  description = "number of validator nodes in devnet"
  type        = number
}

variable "lightclient_count" {
  description = "number of lightclient nodes in devnet"
  type        = number
}

variable "explorer_count" {
  description = "number of explorer nodes in devnet"
  type        = number
}
