terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    bucket = "devops-challenge-tf-state-files"
    key    = "files/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region  = "eu-west-2"
}


module "aws_environment" {
  source = "./modules/aws_environment"

  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
  repo_name = var.repo_name //pass in via command
}

module "ecs_setup" {
  source = "./modules/ecs_setup"
  
  vpc_id = module.aws_environment.vpc_id
  image_url = var.image_url //pass in via command
  ecs_execution_role_arn = module.aws_environment.ecs_execution_role_arn
  ecs_execution_role_name = module.aws_environment.ecs_execution_role_name
  private_subnets = module.aws_environment.private_subnets
  public_subnets = module.aws_environment.public_subnets
  ecs_security_group = module.aws_environment.ecs_security_group
  alb_security_group = module.aws_environment.alb_security_group

  depends_on = [
    module.aws_environment
  ]
}