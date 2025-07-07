variable "client_name" {}
variable "environment" {}
variable "aws_account_id" {}
variable "oidc_role_name" {}
variable "bucket_name" {}
variable "dynamodb_table_name" {}
variable "region" {}

module "vpc" {
  source        = "git::https://github.com/OrganizacionDevOps/OptimizApp_Infraestrucutra_Modular.git//modules/networking/vpc?ref=main"
  
  vpc_name      = "${var.client_name}-${var.environment}-vpc"
  cidr_block    = var.vpc_cidr_block
  environment   = var.environment
  kms_key_id    = var.kms_key_id

  tags = {
    Client      = var.client_name
    Environment = var.environment
  }
}
