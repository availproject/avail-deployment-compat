resource "aws_instance" "full_node" {
  ami           = var.base_ami
  instance_type = var.base_instance_type
  count         = var.full_node_count
  key_name      = var.devnet_key_name
  subnet_id            = element(aws_subnet.devnet_private, count.index).id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name        = format("full-node-%02d", count.index + 1)
    Hostname    = format("full-node-%02d", count.index + 1)
    AvailPort   = format("30%03d", count.index + 1)
    Role        = "full-node"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

resource "aws_instance" "validator" {
  ami                  = var.base_ami
  instance_type        = var.base_instance_type
  count                = var.validator_count
  key_name             = var.devnet_key_name
  subnet_id            = element(aws_subnet.devnet_private, count.index).id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name        = format("validator-%02d", count.index + 1)
    Hostname    = format("validator-%02d", count.index + 1)
    AvailPort   = format("31%03d", count.index + 1)
    Role        = "validator"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}
resource "aws_instance" "explorer" {
  ami                  = var.base_ami
  instance_type        = var.base_instance_type
  count                = var.explorer_count
  key_name             = var.devnet_key_name
  subnet_id            = element(aws_subnet.devnet_private, count.index).id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name        = format("explorer-%02d", count.index + 1)
    Hostname    = format("explorer-%02d", count.index + 1)
    Role        = "explorer"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

