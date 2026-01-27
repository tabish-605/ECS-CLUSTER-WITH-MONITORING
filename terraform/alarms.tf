module "ecs_prod_alarms" {
  source = "../modules/ecs-prod-alarms"

  cluster_name  = "prod-ecs-cluster"
  service_name  = "prod-api-service"
  sns_topic_arn = "arn:aws:sns:us-east-1:588434007010:ecs-alarms"

  tags = {
    Environment = "prod"
    ManagedBy  = "terraform"
  }
}
