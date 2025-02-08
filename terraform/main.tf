terraform {
  backend "s3" {
    bucket = "devops-challenge-tf-state-files"
    key    = "files/terraform.tfstate"
    region = "eu-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}


module "aws_environment" {
  source = "./modules/aws_environment"

  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  repo_name          = var.repo_name //pass in via command
}

module "gateway_setup" {
  source = "./modules/api_gateway_setup"

  path              = var.path
  region            = var.region
  load_balancer_url = module.aws_environment.load_balancer_dns
  lb_sg_id          = module.aws_environment.alb_security_group_id

  depends_on = [
    module.aws_environment
  ]
}

module "ecs_setup" {
  source = "./modules/ecs_setup"

  image_url              = var.image_url //pass in via command
  api_key                = var.api_key   //pass in via command
  ecs_execution_role_arn = module.aws_environment.ecs_execution_role_arn
  private_subnets_ids    = module.aws_environment.private_subnets_ids
  ecs_security_group_id  = module.aws_environment.ecs_security_group_id
  lb_target_group_arn    = module.aws_environment.lb_target_group_arn

  depends_on = [
    module.aws_environment,
    module.gateway_setup
  ]
}