resource "aws_ecs_cluster" "main" {
  name               = var.project
  capacity_providers = var.create_capacity_provider ? [aws_ecs_capacity_provider.capacity_provider[0].name] : null
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  count = var.create_capacity_provider ? 1 : 0

  name = var.capacity_provider_name
  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.aws_autoscaling_group_arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 4
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 85
    }
  }
}
