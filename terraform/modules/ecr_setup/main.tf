resource "aws_ecr_repository" "private_repository" {
  name                 = var.repo_name

  image_scanning_configuration {
    scan_on_push = true
  }
}