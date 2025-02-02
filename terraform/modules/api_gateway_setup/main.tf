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
  rest_api_id              = aws_api_gateway_rest_api.flask_api.id
  resource_id              = aws_api_gateway_resource.flask_resource.id
  http_method              = aws_api_gateway_method.flask_method.http_method
  integration_http_method  = "GET"
  type                     = "HTTP_PROXY" # because it's integration with load balancer; if ECS directly, AWS_PROXY
  uri                      = "http://${var.load_balancer_url}/${var.path}"  # Load Balancer DNS name
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
  rest_api_id  = aws_api_gateway_rest_api.flask_api.id
  stage_name   = "v1"
  deployment_id = aws_api_gateway_deployment.flask_deployment.id
}
