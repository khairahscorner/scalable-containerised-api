terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-west-2"
}


# setup VPC, private/public subnets
module "aws_environment" {
  source = "./modules/aws_environment"

  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
}