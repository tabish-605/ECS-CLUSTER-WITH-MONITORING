module "ecs_ec2" {
  source = "../modules/ecs-ec2"

  cluster_name     = "prod-ecs-ec2"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnets
  instance_type    = "t2.micro"
  desired_capacity = 2
  min_size         = 1
  max_size         = 4

  tags = {
    Environment = "prod"
    ManagedBy  = "terraform"
  }
}
