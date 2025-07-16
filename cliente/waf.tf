module "waf" {
  source = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_waf_module.git?ref=main"

  name               = "waf-app-${var.environment}"
  alb_arn            = module.alb.arn
  tags               = local.tags_common
  allowed_countries  = ["CO", "US"]
}
