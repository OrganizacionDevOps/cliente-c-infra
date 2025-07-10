module "subnets" {
  source = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_subnets_module.git?ref=main"

  vpc_id               = module.vpc.vpc_id
  availability_zones   = var.availability_zones
  environment          = var.environment
  public_cidr_blocks   = var.public_cidr_blocks
  private_cidr_blocks  = var.private_cidr_blocks
}
