module "eips" {
  source       = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_EIP_module.git?ref=main"
  client_name  = var.client_name
  environment  = var.environment
  eip_count    = 1
  tags = {
    Project = "cliente-c"
  }
}