
resource "aws_ecs_cluster" "tech_challenge_app_cluster" {
    name = "tech-challenge-app-cluster"
}

resource "aws_ecs_task_definition" "tech_challenge_app_task_definition" {
    family = "tech-challenge-app-task"
    container_definitions = <<DEFINITION
    [
        {
            "name": "tech-challenge-app",
            "image": "${var.repository_url}",
            "cpu": 256,
            "memory": 512,
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 3000,
                    "hostPort": 3000
                }
            ]
        }
    ]
    DEFINITION
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    memory = 512
    cpu = 256
    execution_role_arn = "${aws_iam_role.ecs_task.arn}"
}

resource "aws_iam_role" "ecs_task" {
    name               = "ecsTask"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "role_policy" {
    role       = "${aws_iam_role.ecs_task.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "tech_challenge_app" {
    name = "tech-challenge-app-service"
    cluster = aws_ecs_cluster.tech_challenge_app_cluster.id
    task_definition = aws_ecs_task_definition.tech_challenge_app_task_definition.arn
    launch_type = "FARGATE"
    desired_count = 1
    network_configuration {
        subnets = [aws_default_subnet.default_subnet.id]
        assign_public_ip = true
    }
}

resource "aws_default_vpc" "default_vpc" {
}

resource "aws_default_subnet" "default_subnet" {
    availability_zone  = "ap-southeast-2a"
}

