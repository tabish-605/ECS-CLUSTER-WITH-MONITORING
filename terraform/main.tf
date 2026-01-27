module "ecs_ec2" {
  source = "../modules/ecs-ec2"

  cluster_name     = var.cluster_name
  vpc_id           = "vpc-033d3f73769d2bfe1"
  subnet_ids       = ["subnet-0d007597e8d8be217", "subnet-015ed8decd8bdea82"]
  instance_type    = "t2.micro"
  desired_capacity = 1
  min_size         = 1
  max_size         = 4

  tags = {
    Environment = "prod"
    ManagedBy  = "terraform"
  }
}
