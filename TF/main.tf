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

resource "aws_iam_role" "BotTelegram_iam" {
  name                = "BotTelegram-IAM"
  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "BotTelegram_iam_attach_roles" {
  for_each    = toset(var.arn_roles_to_iam)
  role        = aws_iam_role.BotTelegram_iam.name
  policy_arn  = each.value
}

resource "aws_iam_instance_profile" "BotTelegram_instanceprofile" {
  name  = "BotTelegram-InstanceProfile"
  role  = aws_iam_role.BotTelegram_iam.name
}

resource "aws_instance" "BotTelegram_ec2" {
  count                  = 2
  ami                    = var.ami_id
  iam_instance_profile   = aws_iam_instance_profile.BotTelegram_instanceprofile.name
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = file("./deploy.sh")
  subnet_id              = module.BotTelegram_vpc.public_subnets[count.index % length(var.subnet_public_cidr)]
  vpc_security_group_ids = [aws_security_group.BotTelegram_sg.id]

  tags = {
      Name = "BotTelegram"
  }
}

resource "aws_lb_target_group" "BotTelegram_tg" {
  name      = "BotTelegram-tg"
  port      = 8443
  protocol  = "HTTP"
  vpc_id    = module.BotTelegram_vpc.vpc_id
}

resource "aws_lb" "BotTelegram_lb" {
  name                = "BotTelegram-lb"
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.BotTelegram_sg.id]
  subnets             = [for subnet in module.BotTelegram_vpc.public_subnets : subnet]
}

resource "aws_acm_certificate" "BotTelegram_cert" {
  domain_name               = "ygdn.online"
  subject_alternative_names = ["ygdn.online", "*.ygdn.online"]
  validation_method         = "DNS"
}

resource "aws_lb_listener" "BotTelegram_lblistener" {
  load_balancer_arn = aws_lb.BotTelegram_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.BotTelegram_cert.arn
  default_action  {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.BotTelegram_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "BotTelegram_attach" {
  count             = length(aws_instance.BotTelegram_ec2)
  target_group_arn  = aws_lb_target_group.BotTelegram_tg.arn
  target_id         = aws_instance.BotTelegram_ec2[count.index].id
  port              = 8443
}

resource "aws_route53_record" "BotTelegram_route53" {
  zone_id = "Z026964130U73763VT0A4"
  name    = "polybot.ygdn.online"
  type    = "A"
  alias {
    name                    = aws_lb.BotTelegram_lb.dns_name
    zone_id                 = aws_lb.BotTelegram_lb.zone_id
    evaluate_target_health  = true
  }
}

resource "aws_launch_template" "BotTelegram_template" {
  name                    = "BotTelegram-template"
  image_id                = var.ami_id
  key_name                = var.key_name
  instance_type           = "t2.medium"
  user_data               = filebase64("./deploy_template.sh")
  vpc_security_group_ids  = [aws_security_group.BotTelegram_sg.id]
  iam_instance_profile    {
    name  = aws_iam_instance_profile.BotTelegram_instanceprofile.name
  }
}

resource "aws_autoscaling_group" "BotTelegram_autoscaling" {
  name                = "BotTelegram-AutoScaling"
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = module.BotTelegram_vpc.public_subnets
  launch_template {
    id      = aws_launch_template.BotTelegram_template.id
    version = "$Latest"
  }
}

output "ip_ec2_list" {
  value       = [for instance in aws_instance.BotTelegram_ec2 : instance.public_ip]
}