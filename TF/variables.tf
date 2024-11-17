# VPC
variable "vpc_cidr" {
   type        = string
}

variable "availability_zone" {
   type        = list
}

variable "subnet_public_cidr" {
   type        = list
}

# EC2
variable "ami_id" {
   type        = string
}

variable "instance_type" {
   type        = string
}

variable "key_name" {
   type        = string
}

# S3
variable "bucket_name" {
   type        = string
}

# SQS
variable "sqs_name" {
   type        = string
}

# SQS
variable "dynamodb_name" {
   type        = string
}

# IAM
variable "arn_roles_to_iam" {
   type        =  list
}

# ROUTE53
variable "domain" {
   type        =  string
}