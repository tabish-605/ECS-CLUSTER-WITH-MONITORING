variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
  default = "prod-ecs-cluster"
}

variable "service_name" {
  type        = string
  description = "ECS service name"
  default = "prod-api-service"
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS topic for alarm notifications"
}

variable "cpu_reservation_threshold" {
  type    = number
  default = 80
}

variable "memory_reservation_threshold" {
  type    = number
  default = 80
}

variable "pending_task_threshold" {
  type    = number
  default = 1
}

variable "task_stopped_threshold" {
  type    = number
  default = 2
}

variable "deployment_timeout_minutes" {
  type    = number
  default = 15
}

variable "tags" {
  type    = map(string)
  default = {}
}
