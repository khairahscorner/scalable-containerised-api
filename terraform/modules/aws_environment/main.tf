module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "DevopsChallenge"
  cidr = var.cidr_block

  azs             = var.availability_zones
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  depends_on = [aws_iam_role.ecsTaskExecutionRole]
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "allow_only_traffic_from_gateway" {
  depends_on = [module.vpc]
  name        = "alb-sg"
  description = "security group for load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] //update this to just the API gateway
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
  depends_on = [aws_security_group.allow_only_traffic_from_gateway]
  name        = "ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow traffic from ALB on port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.allow_only_traffic_from_gateway.id] # Allow only from the ALB
  }

  # Egress rules: Allow all outbound traffic (typical for ECS tasks)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
