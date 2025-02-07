module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "DevopsChallenge"
  cidr = var.cidr_block

  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Sid" : "",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "ecs-tasks.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  depends_on = [aws_iam_role.ecsTaskExecutionRole]
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "allow_only_traffic_from_gateway" {
  depends_on  = [module.vpc]
  name        = "alb-sg"
  description = "security group for load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    # allow only traffic from within public subnet (aka API gateway) into the LB
    cidr_blocks = var.public_subnets
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_only_traffic_from_load_balancer" {
  depends_on  = [aws_security_group.allow_only_traffic_from_gateway]
  name        = "ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow traffic from ALB on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    # Allow only from the ALB
    security_groups = [aws_security_group.allow_only_traffic_from_gateway.id]
  }

  egress {
    description = "Allow all outbound traffic for ECS tasks"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "private_repository" {
  name         = var.repo_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}