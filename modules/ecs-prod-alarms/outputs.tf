output "alarm_names" {
  value = [
    aws_cloudwatch_metric_alarm.ecs_cpu_reservation_high.alarm_name,
    aws_cloudwatch_metric_alarm.ecs_memory_reservation_high.alarm_name,
    aws_cloudwatch_metric_alarm.ecs_service_running_tasks_low.alarm_name,
    aws_cloudwatch_metric_alarm.ecs_pending_tasks.alarm_name,
    aws_cloudwatch_metric_alarm.ecs_task_stopped_spike.alarm_name,
    aws_cloudwatch_metric_alarm.ecs_deployment_stuck.alarm_name,
    aws_cloudwatch_metric_alarm.ecs_container_instances_low.alarm_name
  ]
}
