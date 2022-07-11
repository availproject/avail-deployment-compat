data "aws_caller_identity" "provisioner" {}

# allow ansible to connect with ec2 instances via ssh
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "devnet" {
  key_name   = var.devnet_key_name
  public_key = tls_private_key.pk.public_key_openssh

  # create .pem credentials locally for ssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > /tmp/ansiblePair.pem"
  }
}
