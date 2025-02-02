output "repository_url" {
  value = module.aws_environment.repository_url
}

output "load_balancer_url" {
  value = module.ecs_setup.load_balancer_dns
}

output "api_gateway_url" {
  value = module.gateway_setup.api_gateway_url
}
