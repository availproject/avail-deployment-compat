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
}


resource "aws_key_pair" "devnet" {
  key_name   = var.devnet_key_name
  public_key = var.devnet_key_value
}



# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html


resource "aws_vpc" "devnet" {
  cidr_block       = var.devnet_vpc_block
  instance_tenancy = "default"

  tags = {
    Name = "devnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devnet.id

  tags = {
    Name = "devnet_igw"
  }
}


# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.devnet_public.id

  tags = {
    Name = "nat"
  }
}


resource "aws_subnet" "devnet_private" {
  vpc_id            = aws_vpc.devnet.id
  cidr_block        = var.devnet_private_subnet
  availability_zone = element(var.zones, 0)
  tags = {
    Name = "validator"
  }
}

resource "aws_subnet" "devnet_public" {
  vpc_id                  = aws_vpc.devnet.id
  cidr_block              = var.devnet_public_subnet
  availability_zone       = element(var.zones, 0)
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "fullnode"
  }
}





resource "aws_route_table" "devnet_private" {
  vpc_id = aws_vpc.devnet.id

  tags = {
    Name = "devnet_private_route_table"
  }
}

resource "aws_route_table" "devnet_public" {
  vpc_id = aws_vpc.devnet.id

  tags = {
    Name = "devnet_public_route_table"
  }
}



# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.devnet_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.devnet_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.devnet_public.id
  route_table_id = aws_route_table.devnet_public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.devnet_private.id
  route_table_id = aws_route_table.devnet_private.id
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

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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
    tag-key = "devnet_role"
  }
}

resource "aws_iam_policy" "ec2_policy" {
  name = "ec2_policy"
  path = "/"
  description = "Policy to provide permissin to EC2"
  policy = <<POLYGON
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
}

resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name = "ec2_attachment"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}


resource "aws_instance" "full_node" {
  ami           = var.base_ami
  instance_type = var.base_instance_type
  count         = var.full_node_count
  key_name      = var.devnet_key_name
  subnet_id     = aws_subnet.devnet_public.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = format("full_node_%02d", count.index + 1)
  }
}

resource "aws_instance" "validator" {
  ami           = var.base_ami
  instance_type = var.base_instance_type
  count         = var.validator_count
  key_name      = var.devnet_key_name
  subnet_id     = aws_subnet.devnet_private.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  
  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name = format("validator_%02d", count.index + 1)
  }
}
