output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}

output "ecs_execution_role_name" {
  value = aws_iam_role.ecsTaskExecutionRole.name
}

output "ecs_security_group" {
  value = aws_security_group.allow_only_traffic_from_load_balancer
}

output "alb_security_group" {
  value = aws_security_group.allow_only_traffic_from_gateway
}

output "repository_url" {
  value = aws_ecr_repository.private_repository.repository_url
}