variable "cidr_block" {
  type        = string
  description = "VPC cidr block"
}

variable "availability_zones" {
  type = list(any)
}

variable "public_subnets" {
  type = list(any)
}

variable "private_subnets" {
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

variable "path" {
  type = string
}