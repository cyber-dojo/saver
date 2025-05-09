module "ecs-service" {
  source                           = "s3::https://s3-eu-central-1.amazonaws.com/terraform-modules-9d7e951c290ec5bbe6506e0ddb064808764bc636/terraform-modules.zip//ecs-service/v5"
  service_name                     = var.service_name
  TAGGED_IMAGE                     = var.TAGGED_IMAGE
  enable_execute_command           = "true"
  app_port                         = var.app_port
  cpu_limit                        = var.cpu_limit
  mem_reservation                  = var.mem_reservation
  mem_limit                        = var.mem_limit
  app_env_vars                     = local.app_env_vars
  ecs_wait_for_steady_state        = true
  ecs_service_update_timeout       = "10m"
  container_restart_policy_enabled = var.container_restart_policy_enabled
  volumes = [
    {
      name          = "saver_data"
      containerPath = "/cyber-dojo"
      host_path     = "/ebs_data/cyber-dojo/saver"
    }
  ]
  tags = module.tags.result
}
