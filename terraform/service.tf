resource "aws_ecs_task_definition" "test" {
  family                   = "test-nginx"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/test-nginx"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs_test" {
  name              = "/ecs/test-nginx"
  retention_in_days = 7
}


resource "aws_ecs_service" "test" {
  name            = "test-nginx-service"
  cluster         = "prod-ecs-ec2"
  task_definition = aws_ecs_task_definition.test.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  enable_execute_command = false
}
