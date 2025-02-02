variable "cidr_block" {
  type        = string
  description = "VPC cidr block. Example: 10.10.0.0/16"
}

variable "availability_zones" {
  type = list(any)
}

variable "image_url" {
  type = string
}

variable "repo_name" {
  type = string
}

variable "api_key" {
  type = string
}