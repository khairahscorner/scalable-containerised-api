variable "api_version" {
  default = "v1"
}

resource "aws_api_gateway_rest_api" "flask_api" {
  name        = "flask-api"
  description = "API Gateway for Flask app"
}

resource "aws_api_gateway_resource" "flask_resource" {
  rest_api_id = aws_api_gateway_rest_api.flask_api.id
  parent_id   = aws_api_gateway_rest_api.flask_api.root_resource_id
  path_part   = var.path
}

resource "aws_api_gateway_method" "flask_method" {
  rest_api_id   = aws_api_gateway_rest_api.flask_api.id
  resource_id   = aws_api_gateway_resource.flask_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "flask_integration" {
  rest_api_id             = aws_api_gateway_rest_api.flask_api.id
  resource_id             = aws_api_gateway_resource.flask_resource.id
  http_method             = aws_api_gateway_method.flask_method.http_method
  integration_http_method = "GET"

  # because it's integration with load balancer; if ECS directly, AWS_PROXY
  type = "HTTP_PROXY"
  uri  = "http://${var.load_balancer_url}/${var.path}" # Load Balancer DNS name
}

resource "aws_api_gateway_deployment" "flask_deployment" {
  rest_api_id = aws_api_gateway_rest_api.flask_api.id
  triggers = {
    # hashed all entire resources to ensure all changes to any parts of them trigger a redeployment
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.flask_resource,
      aws_api_gateway_method.flask_method,
      aws_api_gateway_integration.flask_integration
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "flask_stage" {
  depends_on    = [aws_cloudwatch_log_group.gateway_logs]
  rest_api_id   = aws_api_gateway_rest_api.flask_api.id
  stage_name    = var.api_version
  deployment_id = aws_api_gateway_deployment.flask_deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.gateway_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }
}

resource "aws_cloudwatch_log_group" "gateway_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.flask_api.id}/${var.api_version}"
  retention_in_days = 7
}

// update load balancer security group to only allow traffic from created api gateway
data "aws_ip_ranges" "api_gateway" {
  services = ["API_GATEWAY"]
  regions  = [var.region]
}

resource "aws_vpc_security_group_ingress_rule" "allow_only_traffic_from_gateway" {
  description       = "Allow inbound traffic only from API gateway IP ranges"
  for_each          = toset(data.aws_ip_ranges.api_gateway.cidr_blocks)
  security_group_id = var.lb_sg_id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = each.value
}