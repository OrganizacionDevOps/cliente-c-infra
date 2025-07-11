module "route_table_associations" {
  source = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_Route_Table_Associations_module.git?ref=main"

  public_subnet_ids       = module.subnets.public_subnet_ids
  private_subnet_ids      = module.subnets.private_subnet_ids
  public_route_table_id   = module.route_tables.public_route_table_id
  private_route_table_id  = module.route_tables.private_route_table_id
}