terraform {
  backend "s3" {
    bucket         = "terraform-backend-tabish"
    key            = "ecs/prod/terraform.tfstate"
    region         = "us-east-1"
  }
}
