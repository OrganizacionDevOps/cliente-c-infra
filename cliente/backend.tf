module "backend" {
  source              = "../../../modules/backend/aws"
  aws_account_id      = var.aws_account_id
  oidc_role_name      = var.oidc_role_name
  bucket_name         = var.bucket_name
  dynamodb_table_name = var.dynamodb_table_name
  tags = {
    Client      = var.client_name
    Environment = var.environment
  }
}
