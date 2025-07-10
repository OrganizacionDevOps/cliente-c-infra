variable "client_name" {}
variable "environment" {}
variable "aws_account_id" {}
variable "oidc_role_name" {}
variable "bucket_name" {}
variable "dynamodb_table_name" {}
variable "region" {}
variable "vpc_cidr_block" {}
variable "kms_key_id" {}
variable "vpc_id" {}


variable "availability_zones" {
  type = list(string)
}
variable "public_cidr_blocks" {
  description = "CIDR blocks para subnets públicas"
  type        = list(string)
}

variable "private_cidr_blocks" {
  description = "CIDR blocks para subnets privadas"
  type        = list(string)
}