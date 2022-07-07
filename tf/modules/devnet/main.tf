data "aws_caller_identity" "provisioner" {}

resource "aws_key_pair" "devnet" {
  key_name   = var.devnet_key_name
  public_key = var.devnet_key_value
}
