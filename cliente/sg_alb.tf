module "sg_alb" {
  source        = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_sg-alb_module.git?ref=main"
  vpc_id        = module.vpc.vpc_id
  environment   = var.environment
  alb_ports     = [80, 443]
  alb_allowed_cidr_blocks = ["0.0.0.0/0"]
}
