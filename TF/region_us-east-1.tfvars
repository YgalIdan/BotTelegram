vpc_cidr            =   "10.0.0.0/16"
availability_zone   =   ["us-east-1a","us-east-1b"]
subnet_public_cidr  =   ["10.0.1.0/24", "10.0.2.0/24"]
ami_id              =   "ami-0866a3c8686eaeeba"
instance_type       =   "t2.micro"
key_name            =   "Ort-20062024"
bucket_name         =   "botphotoproject"
sqs_name            =   "BotPhotoProject"
dynamodb_name       =   "BotPhotoProject"
arn_roles_to_iam    =   ["arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess", 
                         "arn:aws:iam::aws:policy/AmazonEC2FullAccess", 
                         "arn:aws:iam::aws:policy/AmazonS3FullAccess", 
                         "arn:aws:iam::aws:policy/AmazonSQSFullAccess", 
                         "arn:aws:iam::aws:policy/AmazonVPCFullAccess", 
                         "arn:aws:iam::aws:policy/SecretsManagerReadWrite"]