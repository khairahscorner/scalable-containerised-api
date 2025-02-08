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

output "alb_security_group_id" {
  value = aws_security_group.alb_security_group.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_security_group.id
}

output "repository_url" {
  value = aws_ecr_repository.private_repository.repository_url
}

output "load_balancer_dns" {
  value = aws_lb.alb.dns_name
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.lb-target-group.arn
}