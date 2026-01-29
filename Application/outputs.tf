output "ecr_repository_url" {
  value = aws_ecr_repository.dummy_app.repository_url
}

output "service_name" {
  value = aws_ecs_service.dummy_app.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.dummy_app.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.dummy_app.arn
}