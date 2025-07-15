module "iam_roles" {
  source = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_IAM_Roles_module.git?ref=main"

  client_name          = var.client_name
  environment          = var.environment
  region               = var.region
  account_id           = var.aws_account_id
  bucket_name          = var.bucket_name
  dynamodb_table_name  = var.dynamodb_table_name
  kms_key_arn          = var.kms_key_arn
  project              = "cliente-c-infra"

  # Nuevas variables:
  oidc_provider_arn = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
  oidc_provider_url = "token.actions.githubusercontent.com"
}
