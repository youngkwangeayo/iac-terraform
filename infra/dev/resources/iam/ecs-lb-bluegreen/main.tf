/*
기존 콘솔생성 테라폼 동기화.
- terraform import aws_iam_role.ecs_lb_blue_green dev-ECSLoadBalancerForBlueGreen
- terrafrom plan
# 변경사항 리소스에 추가.
- terraform apply
*/



module "common" {
  source = "../../../../modules/common"
  environment = var.environment
  project_name = var.project_name
}

data "aws_iam_policy_document" "ecs_assume_role_lb" {
  statement {
    sid    = "AllowAccessToECSForInfrastructureManagement"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_lb_blue_green" {
  name               = "${var.environment}-ECSLoadBalancerForBlueGreen"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_lb.json
  description        = "Allows ECS to manage load balancers associated with ECS workloads."

  tags = module.common.common_tags
}


resource "aws_iam_role_policy_attachment" "ecs_lb_infrastructure" {
  role       = aws_iam_role.ecs_lb_blue_green.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSInfrastructureRolePolicyForLoadBalancers"
}

