locals {
  environment = var.environment
  client      = var.client_name  
  project     = var.project

  tags_common = {
    Environment = local.environment
    Client      = local.client
    Project     = local.project
  }
}