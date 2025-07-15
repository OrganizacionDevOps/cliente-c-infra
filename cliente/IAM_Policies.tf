module "iam_roles" {
  source              = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_IAM_Roles_module.git?ref=main"
  client_name         = var.client_name
  bucket_name         = var.bucket_name
  kms_key_arn         = var.kms_key_arn
  region              = var.region
  account_id          = var.aws_account_id
  dynamodb_table_name = var.dynamodb_table_name
}