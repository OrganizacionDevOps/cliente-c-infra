#!/bin/bash

# ─────────────────────────────────────────────────────────────
# Script para inicializar el backend Terraform por cliente
# Crea bucket S3 + tabla DynamoDB desde módulo remoto
# ─────────────────────────────────────────────────────────────

if [ "$#" -ne 5 ]; then
  echo "❌ Uso incorrecto"
  echo "Uso: $0 <client_name> <environment> <region> <aws_account_id> <oidc_role_name>"
  echo "Ejemplo: ./bootstrap.sh cliente-a dev us-east-1 239452641090 GitHubTerraformAccessRole1"
  exit 1
fi

# ─── Variables de entrada ─────────────────────────────────────
CLIENT=$1
ENV=$2
REGION=$3
AWS_ACCOUNT_ID=$4
OIDC_ROLE_NAME=$5
WORKDIR="bootstrap-temp-${CLIENT}-${ENV}"

MODULE_SOURCE="git::https://github.com/OrganizacionDevOps/OptimizApp_Infraestrucutra_Modular.git//modules/backend/aws?ref=main"

# ─── Limpieza previa ─────────────────────────────────────────
echo "🧹 Limpiando residuos anteriores..."
rm -rf "$WORKDIR"
rm -rf .terraform*
rm -f terraform.tfstate* terraform.lock.hcl

sleep 1

# ─── Crear directorio temporal ───────────────────────────────
echo "📂 Creando carpeta de trabajo: $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR" || { echo "❌ No se pudo entrar a $WORKDIR"; exit 1; }

# ─── Generar archivos dinámicos ──────────────────────────────
echo "🛠️ Generando main.tf..."
cat <<EOF > main.tf
variable "client_name" { type = string }
variable "environment" { type = string }
variable "region" { type = string }
variable "aws_account_id" { type = string }
variable "oidc_role_name" { type = string }
variable "bucket_name" { type = string }
variable "dynamodb_table_name" { type = string }

module "backend" {
  source = "${MODULE_SOURCE}"

  client_name         = var.client_name
  environment         = var.environment
  region              = var.region
  aws_account_id      = var.aws_account_id
  oidc_role_name      = var.oidc_role_name
  bucket_name         = var.bucket_name
  dynamodb_table_name = var.dynamodb_table_name
}
EOF

echo "📄 main.tf generado con éxito."

echo "📄 Generando terraform.tfvars..."
cat <<EOF > terraform.tfvars
client_name         = "${CLIENT}"
environment         = "${ENV}"
region              = "${REGION}"
aws_account_id      = "${AWS_ACCOUNT_ID}"
oidc_role_name      = "${OIDC_ROLE_NAME}"
bucket_name         = "terraform-state-${CLIENT}-${ENV}-${AWS_ACCOUNT_ID}"
dynamodb_table_name = "terraform-locks-${CLIENT}-${ENV}-${AWS_ACCOUNT_ID}"
EOF

sleep 1

# ─── Verificación de archivos ────────────────────────────────
echo "🔍 Verificando archivos generados..."
[ -f main.tf ] || { echo "❌ main.tf no se generó"; exit 1; }
[ -f terraform.tfvars ] || { echo "❌ terraform.tfvars no se generó"; exit 1; }

echo "📁 Contenido de $WORKDIR:"
ls -lh

sleep 1

# ─── Terraform Init + Apply ──────────────────────────────────
echo "🚀 Ejecutando terraform init..."
terraform init || { echo "❌ Error en terraform init"; exit 1; }

echo "⏳ Esperando 2 segundos..."
sleep 2

echo "✅ Init completado. Aplicando infraestructura..."
terraform apply -auto-approve -var-file="terraform.tfvars" || { echo "❌ Error en terraform apply"; exit 1; }

# ─── Limpieza opcional (comentar para debug) ─────────────────
cd ..
# rm -rf "$WORKDIR"

echo "🎉 Backend creado exitosamente para cliente '${CLIENT}' en ambiente '${ENV}'"
