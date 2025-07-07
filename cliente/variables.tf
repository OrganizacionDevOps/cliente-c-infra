variable "client_name" {}
variable "environment" {}
variable "aws_account_id" {}
variable "oidc_role_name" {}
variable "bucket_name" {}
variable "dynamodb_table_name" {}
variable "region" {}

variable "vpc_cidr_block" {
  description = "Bloque CIDR para la VPC"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Habilita NAT Gateway (true/false)"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Habilita soporte DNS"
  type        = bool
  default     = true
}
