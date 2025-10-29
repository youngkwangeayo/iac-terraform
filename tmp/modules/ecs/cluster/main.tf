# modules/ecs/cluster/main.tf

resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.env}-${var.cluster_name}"

  tags = merge(
    {
      Name = "${var.project}-${var.env}-${var.cluster_name}"
    },
    var.extra_tags
  )
}

# Cluster Capacity Provider (Fargate, Fargate Spot)
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = lookup(default_capacity_provider_strategy.value, "weight", null)
      base              = lookup(default_capacity_provider_strategy.value, "base", null)
    }
  }
}
