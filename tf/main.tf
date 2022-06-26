terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      Environment = "devnet"
      Network = "avail"
      Owner       = "jhilliard@polygon.technology"
      # this won't work in all cases, but for arbitrary devnets that are being created it should befine
      Lineage = jsondecode(file("terraform.tfstate")).lineage
    }
  }
}

resource "aws_ssm_parameter" "lineage" {
  name  = "terraform-lineage"
  type  = "String"
  value = jsondecode(file("terraform.tfstate")).lineage
}

data "aws_caller_identity" "provisioner" {}

resource "aws_key_pair" "devnet" {
  key_name   = var.devnet_key_name
  public_key = var.devnet_key_value
}



resource "aws_vpc" "devnet" {
  cidr_block       = var.devnet_vpc_block
  instance_tenancy = "default"

  tags = {
    Name = "devnet"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devnet.id

  tags = {
    Name = "igw"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}


# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  count         = length(var.zones)
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.zones)
  subnet_id     = element(aws_subnet.devnet_public, count.index).id
  allocation_id = element(aws_eip.nat_eip, count.index).id

  tags = {
    Name = "nat"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}


resource "aws_subnet" "devnet_private" {
  vpc_id            = aws_vpc.devnet.id
  count             = length(var.zones)
  availability_zone = element(var.zones, count.index)
  cidr_block        = element(var.devnet_private_subnet, count.index)
  tags = {
    Name = "private-subnet"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

resource "aws_subnet" "devnet_public" {
  vpc_id                  = aws_vpc.devnet.id
  count                   = length(var.zones)
  availability_zone       = element(var.zones, count.index)
  cidr_block              = element(var.devnet_public_subnet, count.index)
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "public-subnet"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}





resource "aws_route_table" "devnet_private" {
  vpc_id = aws_vpc.devnet.id
  count = length(var.zones)
  tags = {
    Name = "private_route_table"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

resource "aws_route_table" "devnet_public" {
  vpc_id = aws_vpc.devnet.id

  tags = {
    Name = "public_route_table"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}



# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.devnet_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# # Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = element(aws_route_table.devnet_private, count.index).id
  destination_cidr_block = "0.0.0.0/0"
  count                  = length(var.zones)
  nat_gateway_id         = element(aws_nat_gateway.nat, count.index).id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.zones)
  subnet_id      = element(aws_subnet.devnet_public, count.index).id
  route_table_id = aws_route_table.devnet_public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.zones)
  subnet_id      = element(aws_subnet.devnet_private, count.index).id
  route_table_id = element(aws_route_table.devnet_private, count.index).id
}




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
    self      = "true"
  }
}



resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = <<POLYGON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
POLYGON
  tags = {
    Name = "devnet_role"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  path        = "/"
  description = "Policy to provide permissin to EC2"
  policy      = <<POLYGON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstanceStatus"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ds:CreateComputer",
                "ds:DescribeDirectories"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetEncryptionConfiguration",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads"
            ],
            "Resource": "*"
        }
    ]
}
POLYGON
  tags = {
    Name = "devnet_role"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }

}

resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name       = "ec2_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}


resource "aws_instance" "full_node" {
  ami                  = var.base_ami
  instance_type        = var.base_instance_type
  count                = var.full_node_count
  key_name             = var.devnet_key_name
  subnet_id            = element(aws_subnet.devnet_public, count.index).id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name     = format("full-node-%02d", count.index + 1)
    Hostname = format("full-node-%02d", count.index + 1)
    Role     = "full-node"
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
    Name     = format("validator-%02d", count.index + 1)
    Hostname = format("validator-%02d", count.index + 1)
    Role     = "validator"
    Provisioner = data.aws_caller_identity.provisioner.account_id
  }
}
