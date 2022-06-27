# Default Security Group of VPC
resource "aws_security_group" "default" {
  name        = "default-sg"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id      = aws_vpc.devnet.id
  depends_on = [
    aws_vpc.devnet
  ]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
}

resource "aws_security_group" "allow_internal" {
  name        = "avail-all-nodes"
  description = "Allow all internal traffic"
  vpc_id      = aws_vpc.devnet.id
}

resource "aws_security_group_rule" "allow_internal" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.devnet.cidr_block]
  security_group_id = aws_security_group.allow_internal.id
}
resource "aws_network_interface_sg_attachment" "sg_validator_attachment" {
  count                = length(aws_instance.validator)
  security_group_id    = aws_security_group.allow_internal.id
  network_interface_id = element(aws_instance.validator, count.index).primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "sg_full_node_attachment" {
  count                = length(aws_instance.full_node)
  security_group_id    = aws_security_group.allow_internal.id
  network_interface_id = element(aws_instance.full_node, count.index).primary_network_interface_id
}
resource "aws_security_group" "allow_p2p_validator" {
  count       = length(aws_instance.validator)
  name        = format("allow-p2p-validator-%02d", count.index + 1)
  description = "Allow all p2p traffic"
  vpc_id      = aws_vpc.devnet.id
}
resource "aws_security_group" "allow_p2p_full_node" {
  count       = length(aws_instance.full_node)
  name        = format("allow-p2p-full-node-%02d", count.index + 1)
  description = "Allow all p2p traffic"
  vpc_id      = aws_vpc.devnet.id
}
resource "aws_security_group_rule" "allow_internal_validator" {
  count             = length(aws_instance.validator)
  type              = "ingress"
  from_port         = element(aws_instance.validator, count.index).tags.AvailPort
  to_port           = element(aws_instance.validator, count.index).tags.AvailPort
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = element(aws_security_group.allow_p2p_validator, count.index).id
}
resource "aws_security_group_rule" "allow_internal_full_node" {
  count             = length(aws_instance.full_node)
  type              = "ingress"
  from_port         = element(aws_instance.full_node, count.index).tags.AvailPort
  to_port           = element(aws_instance.full_node, count.index).tags.AvailPort
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = element(aws_security_group.allow_p2p_full_node, count.index).id
}
resource "aws_network_interface_sg_attachment" "sg_validator_attachment_p2p" {
  count                = length(aws_instance.validator)
  security_group_id    = element(aws_security_group.allow_p2p_validator, count.index).id
  network_interface_id = element(aws_instance.validator, count.index).primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "sg_full_node_attachment_p2p" {
  count                = length(aws_instance.full_node)
  security_group_id    = element(aws_security_group.allow_p2p_full_node, count.index).id
  network_interface_id = element(aws_instance.full_node, count.index).primary_network_interface_id
}



resource "aws_security_group" "allow_rpc_full_node" {
  name        = "allow-rpc-full-node"
  description = "Allow all rpc and ws traffic"
  vpc_id      = aws_vpc.devnet.id
}

resource "aws_security_group_rule" "allow_full_node_rpc" {
  type              = "ingress"
  from_port         = var.avail_rpc_port
  to_port           = var.avail_rpc_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_rpc_full_node.id
}
resource "aws_security_group_rule" "allow_full_node_ws" {
  type              = "ingress"
  from_port         = var.avail_ws_port
  to_port           = var.avail_ws_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_rpc_full_node.id
}
resource "aws_network_interface_sg_attachment" "sg_full_node_attachment_rpc" {
  count                = length(aws_instance.full_node)
  security_group_id    = aws_security_group.allow_rpc_full_node.id
  network_interface_id = element(aws_instance.full_node, count.index).primary_network_interface_id
}

