#Creates S3 Bucket & configures as backend for State files

provider "aws" {
  region  =  "eu-west-2"
}

#terraform state file setup
#Create s3 bucket

resource "aws_s3_bucket" "terraform_state_backup" {
  bucket =  "phunkytech-tf-state-s3"

  versioning {
    enabled  =  true
  }

  lifecycle {
    prevent_destroy = true 
  }
  
  tags {
    Name  =  "S3 Remote Terraform State Store"
  }
}

#create the s3 backend resource

terraform {
  backend  "s3" {
  encrypt = true
  bucket  = "phunkytech-tf-state-s3"
  dynamodb_table = "phunky-tf-lock-dynamo"
  region  =  "eu-west-2"
  key     =  "home/bruce/terraform/terra-sample/terraform.tfstate"
  }
}

resource "aws_dynamodb_table" "phunky-dynamodb-tf-lock" {
  name  =  "phunky-tf-lock-dynamo"
  hash_key  =  "LockID"
  read_capacity  =  20
  write_capacity =  20

  attribute  {
    name  = "LockID"
    type  = "S"
  }

  tags {
    Name   =  "DynamoDB Terraform State Lock Table"
  }
}
