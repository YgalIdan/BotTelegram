terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.55"
    }
  }

  backend "s3" {
    bucket = "ygal-tf-state"
    key    = "BotTelegram"
    region = "us-east-1"
  }

  required_version = ">= 1.7.0"
}

module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  name    = var.sqs_name
}

module "BotTelegram_vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "5.8.1"
  name                    = "TF-BotTelegram-VPC"
  cidr                    = var.vpc_cidr
  azs                     = var.availability_zone
  public_subnets          = var.subnet_public_cidr
  enable_nat_gateway      = false
  map_public_ip_on_launch = true

  tags = {
    Env = "BotTelegram"
  }
}

resource "aws_s3_bucket" "BotTelegram_s3" {
  bucket  = var.bucket_name
}

resource "aws_dynamodb_table" "BotTelegram_dynamodb" {
  name            = var.dynamodb_name
  billing_mode    = "PROVISIONED"
  read_capacity   = 1
  write_capacity  = 1
  hash_key        = "prediction_id"
  attribute {
    name = "prediction_id"
    type = "S"
  }
}

resource "aws_security_group" "BotTelegram_sg" {
  name          = "TF-BotTelegram-SG"
  vpc_id        = module.BotTelegram_vpc.vpc_id

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "BotTelegram_ec2" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = file("./deploy.sh")
  subnet_id              = module.BotTelegram_vpc.public_subnets[count.index % length(var.subnet_public_cidr)]
  vpc_security_group_ids = [aws_security_group.BotTelegram_sg.id]

  tags = {
      Name = "BotTelegram"
  }
}