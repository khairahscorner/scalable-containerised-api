resource "aws_ecs_task_definition" "flask-task" {
  family                   = "flask-apis"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.ecs_execution_role_arn
  cpu                      = 256
  memory                   = 512

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
      environment = [
        {
          name  = "OPENWEATHER_API_KEY"
          value = var.api_key
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
  launch_type     = "FARGATE"

  desired_count        = 2
  force_new_deployment = true
  network_configuration {
    subnets         = var.private_subnets_ids
    security_groups = [var.ecs_security_group_id]
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = "flask-container"
    container_port   = 80
  }
}