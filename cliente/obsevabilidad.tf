module "observability" {
  source              = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_observability_module.git?ref=main"
  alb_name            = module.alb.lb_name
  nat_gateway_id      = module.nat_gateway.nat_id
  vpc_log_group_name  = "vpc-flow-logs-${var.environment}"
  environment         = var.environment
  region              = var.region
  tags                = local.tags_common
}