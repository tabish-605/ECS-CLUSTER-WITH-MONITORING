terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    # Configure your S3 backend
    bucket = "bucket=terraform-backend-tabish"
    key    = "ecs-alarm-test/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ecs_cluster" "prod_cluster" {
  cluster_name = "prod-ecs-cluster"
}

# Dummy Application ECR Repository
resource "aws_ecr_repository" "dummy_app" {
  name                 = "dummy-alarm-test-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "Test"
    Purpose     = "Alarm Testing"
  }
}

# Task Definition for Dummy App
resource "aws_ecs_task_definition" "dummy_app" {
  family                   = "dummy-alarm-test-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 256    # 0.25 vCPU
  memory                   = 512    # 512 MB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "dummy-app"
    image     = "${aws_ecr_repository.dummy_app.repository_url}:latest"
    cpu       = 256
    memory    = 512
    essential = true

    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]

    environment = [
      {
        name  = "ENVIRONMENT"
        value = "test"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/dummy-alarm-test-app"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }])

  tags = {
    Environment = "Test"
    Purpose     = "Alarm Testing"
  }
}

# IAM Roles
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-alarm-test-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-alarm-test-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# ECS Service for Testing
resource "aws_ecs_service" "dummy_app" {
  name            = "dummy-alarm-test-service"
  cluster         = data.aws_ecs_cluster.prod_cluster.id
  task_definition = aws_ecs_task_definition.dummy_app.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = data.aws_ecs_cluster.prod_cluster.capacity_providers[0]
    weight            = 1
    base              = 0
  }

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dummy_app.arn
    container_name   = "dummy-app"
    container_port   = 8080
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Environment = "Test"
    Purpose     = "Alarm Testing"
  }
}

# Security Group
resource "aws_security_group" "ecs_service" {
  name        = "dummy-app-alarm-test-sg"
  description = "Security group for dummy app alarm testing"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "dummy_app" {
  name        = "dummy-alarm-test-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Environment = "Test"
    Purpose     = "Alarm Testing"
  }
}

# CloudWatch Dashboard for Monitoring
resource "aws_cloudwatch_dashboard" "alarm_testing" {
  dashboard_name = "ECS-Alarm-Testing-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "dummy-alarm-test-service", "ClusterName", "prod-ecs-cluster"],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Dummy App - CPU & Memory"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUReservation", "ClusterName", "prod-ecs-cluster"],
            [".", "MemoryReservation", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Cluster Reservation"
        }
      }
    ]
  })
}