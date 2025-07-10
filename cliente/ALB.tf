module "alb" {
  source            = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_AWS_ALB_module.git?ref=main"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.subnets.public_subnet_ids
  alb_sg_id         = module.sg_alb.alb_sg_id
  environment       = var.environment
}