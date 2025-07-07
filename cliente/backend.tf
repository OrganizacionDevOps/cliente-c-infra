module "backend" {
  source              = "git::https://github.com/OrganizacionDevOps/OptimizApp_Infraestrucutra_Modular.git//modules/backend/aws?ref=main"

  client_name         = var.client_name
  environment         = var.environment
  region              = var.region                  # 👈 SOLUCIÓN
  aws_account_id      = var.aws_account_id
  oidc_role_name      = var.oidc_role_name
  bucket_name         = var.bucket_name
  dynamodb_table_name = var.dynamodb_table_name
}
