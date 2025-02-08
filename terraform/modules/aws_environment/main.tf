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

resource "aws_security_group" "alb_security_group" {
  depends_on  = [module.vpc]
  name        = "alb-sg"
  description = "security group for load balancer"
  vpc_id      = module.vpc.vpc_id
}

// ingress rule to only allow traffic from API gateway is created after the gateway has been created

resource "aws_vpc_security_group_egress_rule" "allow_all_lb_traffic_out" {
  security_group_id = aws_security_group.alb_security_group.id
  description       = "Allow all outbound traffic from ALB"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "ecs_security_group" {
  depends_on  = [aws_security_group.alb_security_group]
  name        = "ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_only_traffic_from_lb" {
  security_group_id = aws_security_group.ecs_security_group.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  description                  = "Allow inbound traffic only from ALB on port 80"
  referenced_security_group_id = aws_security_group.alb_security_group.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_out" {
  security_group_id = aws_security_group.ecs_security_group.id
  description       = "Allow all outbound traffic from ECS tasks"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_lb" "alb" {
  name               = "flask-apis-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "lb-target-group" {
  name        = "flask-apis-lb-tg"
  protocol    = "HTTP"
  port        = 80
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "lb-listener" {
  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = aws_lb.alb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }
}

resource "aws_ecr_repository" "private_repository" {
  name         = var.repo_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}