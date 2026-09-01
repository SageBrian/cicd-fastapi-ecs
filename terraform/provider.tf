terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  # Remote state - create this S3 bucket + DynamoDB lock table once, by hand
  # or via a small bootstrap script, before running `terraform init`.
  backend "s3" {
    bucket         = "REPLACE-ME-terraform-state-bucket"
    key            = "cicd-fastapi-ecs/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "REPLACE-ME-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
