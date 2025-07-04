#!/bin/bash

# ...existing code...
if [ "$#" -ne 5 ]; then
  echo "Uso: $0 <client_name> <environment> <region> <aws_account_id> <oidc_role_name>"
  echo "Ejemplo: ./bootstrap.sh cliente-a dev us-east-1 214549340225 GitHubTerraformAccessRole"
  exit 1
fi

CLIENT=$1
ENV=$2
REGION=$3
AWS_ACCOUNT_ID=$4
OIDC_ROLE_NAME=$5
WORKDIR="bootstrap-temp-$CLIENT-$ENV"

mkdir -p $WORKDIR
cd $WORKDIR

cat <<EOF > main.tf
variable "client_name" { type = string }
variable "environment" { type = string }
variable "region"      { type = string }
variable "aws_account_id" { type = string }
variable "oidc_role_name" { type = string }
variable "bucket_name" { type = string }
variable "dynamodb_table_name" { type = string }

module "backend" {
  source         = "../modules/backend/aws"
  client_name    = var.client_name
  environment    = var.environment
  region         = var.region
  aws_account_id = var.aws_account_id
  oidc_role_name = var.oidc_role_name
  bucket_name         = var.bucket_name
  dynamodb_table_name = var.dynamodb_table_name
}
EOF

cat <<EOF > terraform.tfvars
client_name         = "${CLIENT}"
environment         = "${ENV}"
region              = "${REGION}"
aws_account_id      = "${AWS_ACCOUNT_ID}"
oidc_role_name      = "${OIDC_ROLE_NAME}"
bucket_name         = "terraform-state-${CLIENT}-${ENV}-${AWS_ACCOUNT_ID}"
dynamodb_table_name = "terraform-locks-${CLIENT}-${ENV}-${AWS_ACCOUNT_ID}"
EOF
# ...existing code...
# ─── Ejecutar Terraform para crear backend ───────────────────────────────────
terraform init
terraform apply -auto-approve -var-file="terraform.tfvars"

# ─── Limpieza opcional ───────────────────────────────────────────────────────
cd ..
rm -rf $WORKDIR

echo "✅ Backend creado para cliente '$CLIENT' en ambiente '$ENV'"
