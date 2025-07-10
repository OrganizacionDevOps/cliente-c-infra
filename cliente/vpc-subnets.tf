module "subnets" {
  source = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_subnets_module.git?ref=main"

  vpc_id              = var.vpc_id
  cidr_blocks         = var.cidr_blocks
  availability_zones  = var.availability_zones
  environment         = var.environment
}
