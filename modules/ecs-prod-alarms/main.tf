resource "aws_cloudwatch_metric_alarm" "ecs_cpu_reservation_high" {
  alarm_name          = "${var.cluster_name}-ecs-cpu-reservation-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_reservation_threshold

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = "ECS cluster CPU reservation too high"
  alarm_actions     = [var.sns_topic_arn]

  tags = var.tags
}


resource "aws_cloudwatch_metric_alarm" "ecs_memory_reservation_high" {
  alarm_name          = "${var.cluster_name}-ecs-memory-reservation-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.memory_reservation_threshold

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = "ECS cluster memory reservation too high"
  alarm_actions     = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_running_tasks_low" {
  alarm_name          = "${var.service_name}-running-tasks-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  threshold           = 1

  metric_query {
    id = "running"
    metric {
      metric_name = "RunningTaskCount"
      namespace   = "AWS/ECS"
      period      = 60
      stat        = "Average"
      dimensions = {
        ClusterName = var.cluster_name
        ServiceName = var.service_name
      }
    }
  }

  metric_query {
    id = "desired"
    metric {
      metric_name = "DesiredTaskCount"
      namespace   = "AWS/ECS"
      period      = 60
      stat        = "Average"
      dimensions = {
        ClusterName = var.cluster_name
        ServiceName = var.service_name
      }
    }
  }

  comparison_operator = "LessThanThreshold"
  threshold           = 0
  evaluation_periods  = 1

  alarm_description = "ECS service running tasks less than desired"
  alarm_actions     = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_pending_tasks" {
  alarm_name          = "${var.service_name}-pending-tasks"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "PendingTaskCount"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.pending_task_threshold

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_description = "ECS service has pending tasks for too long"
  alarm_actions     = [var.sns_topic_arn]

  tags = var.tags
}


resource "aws_cloudwatch_metric_alarm" "ecs_task_stopped_spike" {
  alarm_name          = "${var.service_name}-task-stopped-spike"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TaskStoppedCount"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Sum"
  threshold           = var.task_stopped_threshold

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_description = "High number of ECS task stops detected"
  alarm_actions     = [var.sns_topic_arn]

  tags = var.tags
}


resource "aws_cloudwatch_metric_alarm" "ecs_deployment_stuck" {
  alarm_name          = "${var.service_name}-deployment-stuck"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DeploymentCount"
  namespace           = "AWS/ECS"
  period              = var.deployment_timeout_minutes * 60
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_description = "ECS deployment running too long"
  alarm_actions     = [var.sns_topic_arn]

  tags = var.tags
}


resource "aws_cloudwatch_metric_alarm" "ecs_container_instances_low" {
  alarm_name          = "${var.cluster_name}-container-instances-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ContainerInstanceCount"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = "ECS container instances dropped unexpectedly"
  alarm_actions     = [var.sns_topic_arn]

  tags = var.tags
}
