# ECS cluster
resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "jenkins-ecs-cluster"

  tags = {
    Name = "jenkins-ecs-cluster"
  }
}

# EFS for Jenkins home
resource "aws_efs_file_system" "jenkins_efs" {
  creation_token = "jenkins-efs"
  encrypted      = true

 lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "jenkins-efs"
  }
}

resource "aws_efs_mount_target" "jenkins_efs_mt" {
  for_each = var.private_subnet_ids

  file_system_id  = aws_efs_file_system.jenkins_efs.id
  subnet_id       = each.value
  security_groups = [var.efs_sg_id]

  lifecycle {
  create_before_destroy = true
}

}


# ALB for Jenkins
resource "aws_lb" "jenkins_alb" {
  name               = "jenkins-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "jenkins-alb"
  }
}


resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"


  health_check {
    path                = "/login"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  tags = {
    Name = "jenkins-tg"
  }
}

resource "aws_lb_listener" "jenkins_http_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }
}

# IAM role for Jenkins task
resource "aws_iam_role" "jenkins_task_role" {
  name = "jenkins-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "jenkins-task-role"
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_task_role_policy" {
  role       = aws_iam_role.jenkins_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Execution role for pulling image, logs, etc.
resource "aws_iam_role" "jenkins_execution_role" {
  name = "jenkins-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "jenkins-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_execution_role_policy" {
  role       = aws_iam_role.jenkins_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch log group
resource "aws_cloudwatch_log_group" "jenkins_logs" {
  name              = "/ecs/jenkins"
  retention_in_days = 7

  tags = {
    Name = "jenkins-logs"
  }
}

################################
# EFS ACCESS POINT RESOURCE
###############################
resource "aws_efs_access_point" "jenkins_ap" {
  file_system_id = aws_efs_file_system.jenkins_efs.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/jenkins"
    creation_info {
      owner_uid = 1000
      owner_gid = 1000
      permissions = "0755"
    }
  }
}


# ECS task definition for Jenkins
resource "aws_ecs_task_definition" "jenkins_fargate_task" {
  family = "jenkins-fargate-task"

  revision                 = null
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.jenkins_fargate_cpu
  memory                   = var.jenkins_fargate_memory
  execution_role_arn       = aws_iam_role.jenkins_execution_role.arn
  task_role_arn            = aws_iam_role.jenkins_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "jenkins"
      image     = "jenkins/jenkins:lts"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "JENKINS_ADMIN_ID"
          value = var.jenkins_admin_user
        },
        {
          name  = "JENKINS_ADMIN_PASSWORD"
          value = var.jenkins_admin_pass
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "jenkins-home"
          containerPath = "/var/jenkins_home"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.jenkins_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "jenkins"
        }
      }
    }
  ])

  volume {
    name = "jenkins-home"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.jenkins_efs.id
      transit_encryption      = "ENABLED"
      root_directory          = ""
      authorization_config {
        access_point_id = aws_efs_access_point.jenkins_ap.id
        iam             = "ENABLED"

      }
    }
  }
}

# ECS service for Jenkins
resource "aws_ecs_service" "jenkins_service" {
  name            = "jenkins-service"
  cluster         = aws_ecs_cluster.jenkins_cluster.id
  task_definition = aws_ecs_task_definition.jenkins_fargate_task.arn

  launch_type     = "FARGATE"
  desired_count   = 1
  enable_execute_command = true
  
# Allow Jenkins time to boot before ALB health checks
  health_check_grace_period_seconds = 180

  network_configuration {
    subnets         = values(var.private_subnet_ids)
    security_groups = [var.task_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
    container_name   = "jenkins"
    container_port   = 8080
  }

  depends_on = [
    aws_lb_listener.jenkins_http_listener,
    aws_efs_mount_target.jenkins_efs_mt,
    aws_lb_target_group.jenkins_tg
  ]

  tags = {
    Name = "jenkins-service"
  }
}
