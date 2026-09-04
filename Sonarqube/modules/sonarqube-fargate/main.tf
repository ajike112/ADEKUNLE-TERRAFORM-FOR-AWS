########################
# Security groups
########################

resource "aws_security_group" "sonarqube_alb_sg" {
  name   = "${local.prefix}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "sonarqube_app_sg" {
  name   = "${local.prefix}-app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.sonarqube_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "sonarqube_rds_sg" {
  name   = "${local.prefix}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sonarqube_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "sonarqube_efs_sg" {
  name        = "${local.prefix}-efs-sg"
  description = "Allow NFS traffic from ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description    = "Allow NFS from ECS task SG"
    from_port      = 2049
    to_port        = 2049
    protocol       = "tcp"
    security_groups = [aws_security_group.sonarqube_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

########################
# RDS PostgreSQL
########################

resource "aws_db_subnet_group" "sonarqube_db_subnet" {
  name       = "${local.prefix}-db-subnet"
  subnet_ids = var.private_subnets

  tags = local.tags
}

resource "aws_db_instance" "sonarqube_db" {
  identifier        = "${local.prefix}-db"
  engine            = "postgres"
  engine_version    = "14.24"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_name           = "sonarqube"
  username          = "sonar"
  password          = data.aws_secretsmanager_secret_version.db_password.secret_string

  db_subnet_group_name   = aws_db_subnet_group.sonarqube_db_subnet.name
  vpc_security_group_ids = [aws_security_group.sonarqube_rds_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false


  tags = local.tags
}

########################
# EFS for SonarQube data
########################

resource "aws_efs_file_system" "sonarqube_efs" {
  creation_token = "${local.prefix}-efs"
  encrypted      = true

  
  tags = local.tags
}

resource "aws_efs_access_point" "sonarqube_ap" {
  file_system_id = aws_efs_file_system.sonarqube_efs.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/sonarqube"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }

  tags = local.tags
}

resource "aws_efs_mount_target" "sonarqube_efs_mt" {
  for_each = toset(var.private_subnets)

  file_system_id  = aws_efs_file_system.sonarqube_efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.sonarqube_efs_sg.id]
}

################################
# ECS cluster for SonarQube
################################

resource "aws_ecs_cluster" "sonarqube_cluster" {
  name = "${local.prefix}-cluster"


  tags = local.tags
}

########################
# IAM roles
########################

resource "aws_iam_role" "ecs_execution_role" {
  name = "${local.prefix}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${local.prefix}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "efs_access" {
  name = "${local.prefix}-efs-access"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeMountTargets"
        ]
        Resource = "*"
      }
    ]
  })
}

########################
# ECS Task Definition
########################

resource "aws_cloudwatch_log_group" "sonarqube" {
  name              = "/ecs/${local.prefix}"
  retention_in_days = 30

  tags = local.tags
}

resource "aws_ecs_task_definition" "sonarqube" {
  family                   = "${local.prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "sonarqube"
      image     = "sonarqube:lts-community"
      essential = true

      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SONAR_JDBC_URL"
          value = "jdbc:postgresql://${aws_db_instance.sonarqube_db.address}:5432/sonarqube"
        },
        {
          name  = "SONAR_JDBC_USERNAME"
          value = "sonar"
        },
        {
          name  = "SONAR_JDBC_PASSWORD"
          value = data.aws_secretsmanager_secret_version.db_password.secret_string
        }
      ]

      mountPoints = [
        { sourceVolume = "sonarqube-data", containerPath = "/opt/sonarqube/data" }
      ]

      ulimits = [
        {
          name      = "nofile"
          softLimit = 65536
          hardLimit = 65536
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.sonarqube.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  volume {
    name = "sonarqube-data"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.sonarqube_efs.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999

      authorization_config {
        access_point_id = aws_efs_access_point.sonarqube_ap.id
        iam             = "ENABLED"
      }
    }
  }

  tags = local.tags
}

########################
# ALB + Target Group + Listener
########################

resource "aws_lb" "sonarqube_alb" {
  name               = "${local.prefix}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.sonarqube_alb_sg.id]



  tags = local.tags
}

resource "aws_lb_target_group" "sonarqube_tg" {
  name        = "${local.prefix}-tg"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/system/status"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }

  tags = local.tags
}

resource "aws_lb_listener" "sonarqube_listener" {
  load_balancer_arn = aws_lb.sonarqube_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonarqube_tg.arn
  }
}

########################
# ECS Service + Autoscaling
########################

resource "aws_ecs_service" "sonarqube" {
  name            = "${local.prefix}-service"
  cluster         = aws_ecs_cluster.sonarqube_cluster.id
  task_definition = aws_ecs_task_definition.sonarqube.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.sonarqube_app_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sonarqube_tg.arn
    container_name   = "sonarqube"
    container_port   = 9000
  }

  depends_on = [
    aws_lb_listener.sonarqube_listener
  ]

  tags = local.tags
}

resource "aws_appautoscaling_target" "sonarqube" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.sonarqube_cluster.name}/${aws_ecs_service.sonarqube.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_scale_up" {
  name               = "${local.prefix}-cpu-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.sonarqube.resource_id
  scalable_dimension = aws_appautoscaling_target.sonarqube.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sonarqube.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "PercentChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 50
    }
  }
}
