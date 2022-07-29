resource "aws_instance" "full_node" {
  ami                  = var.base_ami
  instance_type        = var.base_instance_type
  count                = var.full_node_count
  key_name             = var.devnet_key_name
  subnet_id            = element(aws_subnet.devnet_private, count.index).id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name        = format("full-node-%s-%02d", var.deployment_name, count.index + 1)
    Hostname    = format("full-node-%s-%02d", var.deployment_name, count.index + 1)
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
    Name        = format("validator-%s-%02d", var.deployment_name, count.index + 1)
    Hostname    = format("validator-%s-%02d", var.deployment_name, count.index + 1)
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
    Name        = format("explorer-%s-%02d", var.deployment_name, count.index + 1)
    Hostname    = format("explorer-%s-%02d", var.deployment_name, count.index + 1)
    Role        = "explorer"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

resource "aws_instance" "light_client" {
  ami                  = var.base_ami
  instance_type        = var.base_instance_type
  count                = var.light_client_count
  key_name             = var.devnet_key_name
  subnet_id            = element(aws_subnet.devnet_private, count.index).id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name        = format("light-client-%s-%02d", var.deployment_name, count.index + 1)
    Hostname    = format("light-client-%s-%02d", var.deployment_name, count.index + 1)
    Role        = "light-client"
    LightPort   = format("32%03d", count.index + 1)
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

