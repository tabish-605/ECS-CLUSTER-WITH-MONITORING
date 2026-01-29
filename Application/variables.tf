variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for ECS cluster"
  type        = string
  default = "vpc-033d3f73769d2bfe1"
}

variable "private_subnets" {
  description = "Private subnets for ECS tasks"
  type        = list(string)
  default = ["subnet-0d007597e8d8be217", "subnet-015ed8decd8bdea82"]
}

variable "desired_count" {
  description = "Number of dummy app tasks to run"
  type        = number
  default     = 1
}