module "ecs_prod_alarms" {
  source = "../modules/ecs-prod-alarms"

  cluster_name  = "prod-ecs-cluster"
  service_name  = "prod-api-service"
  sns_topic_arn = aws_sns_topic.prod_alerts.arn

  tags = {
    Environment = "prod"
    ManagedBy  = "terraform"
  }
}
