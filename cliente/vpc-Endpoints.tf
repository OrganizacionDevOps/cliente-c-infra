module "vpc_endpoints" {
  source = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_VPC_Endpoints_module.git?ref=main"

  vpc_id             = module.vpc.vpc_id
  region             = var.region
  gateway_services   = ["s3", "dynamodb"]
  interface_services = ["ssm", "secretsmanager"]
  route_table_ids    = module.route_tables.ids
  subnet_ids         = module.subnets.private_subnet_ids
  security_group_ids = [module.sg.id]
  client_name        = var.client_name
  environment        = var.environment
  tags = {
    Project = "cliente-c"
  }
}