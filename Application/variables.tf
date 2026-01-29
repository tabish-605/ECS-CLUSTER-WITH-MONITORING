variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for ECS cluster"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets for ECS tasks"
  type        = list(string)
}

variable "desired_count" {
  description = "Number of dummy app tasks to run"
  type        = number
  default     = 1
}