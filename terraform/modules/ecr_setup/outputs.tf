output "repository_arn" {
  value       = aws_ecr_repository.private_repository.arn
}

output "repository_url" {
  value = aws_ecr_repository.private_repository.repository_url
}