resource "aws_lb" "alb" {
  name               = "flask-apis-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group.id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "lb-target-group" {
  name        = "flask-apis-lb-tg"
  protocol    = "HTTP"
  port        = 80
  target_type = "ip"
  vpc_id      = var.vpc_id
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

resource "aws_ecs_task_definition" "flask-task" {
  family = "flask-apis"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  execution_role_arn = var.ecs_execution_role_arn
  container_definitions = jsonencode([
    {
      name      = "flask-container"
      image     = var.image_url
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_cluster" "flask-apis-cluster" {
  name = "flask-apis-cluster"

  setting {
    name  = "containerInsights" //for cloudwatch
    value = "enabled"
  }
}

resource "aws_ecs_service" "flask-service" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.flask-apis-cluster.arn
  task_definition = aws_ecs_task_definition.flask-task.arn
  launch_type = "FARGATE"

  desired_count   = 2
  force_new_deployment = true
  network_configuration {
    subnets = var.private_subnets
    security_groups = [var.ecs_security_group.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb-target-group.arn
    container_name   = "flask-container"
    container_port   = 80
  }
}