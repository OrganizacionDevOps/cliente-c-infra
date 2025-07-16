module "waf" {
  source = "../modules/Optimizapp_waf_module"

  name              = "waf-alb-cliente-c"
  alb_arn           = module.alb.arn
  allowed_countries = ["CO", "US"]
  tags = {
    Environment = "dev"
    Owner       = "platform-team"
  }
}