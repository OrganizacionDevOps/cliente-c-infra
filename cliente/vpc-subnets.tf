module "subnets" {
  source  = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_subnets_module.git?ref=main"

  vpc_id              = var.vpc_id
  public_cidr_block   = var.public_cidr_block
  private_cidr_block  = var.private_cidr_block
  availability_zone   = var.availability_zone
  environment         = var.environment
}
