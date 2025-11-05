# ============================================================================
# ECS Task Execution Role
# ============================================================================

# Trust Policy for ECS Tasks
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  description        = "ECS Task Execution Role for pulling images and writing logs"

  tags = {
    Name        = "ecsTaskExecutionRole"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Attach AWS managed policies (기존 정책 유지)
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_iot" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ssm" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_logs" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# ============================================================================
# ECS Task Role
# ============================================================================

# ECS Task Role (for application to access AWS resources)
resource "aws_iam_role" "ecs_task" {
  name               = "ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  description        = "Allows ECS tasks to call AWS services on your behalf."

  tags = {
    Name        = "ecsTaskRole"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Attach AWS managed policies for Task Role (기존 정책 유지)
resource "aws_iam_role_policy_attachment" "ecs_task_iot" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AWSIoTFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_logs" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_efs" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}
