module "internet_gateway" {
  source      = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_Internet_Gateway_module.git?ref=main"
  
  vpc_id      = module.vpc.vpc_id
  client_name = var.client_name        # aquí pasas la variable que sí tienes
  environment = var.environment
  tags = {
    Project = "cliente-c"
  }
}
