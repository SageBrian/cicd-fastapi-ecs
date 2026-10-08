terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  # Remote state stored and locked in S3.
  backend "s3" {
    bucket       = "cicd-fastapi-ecs-tfstate-723468076990"
    key          = "cicd-fastapi-ecs/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}
