client_name          = "cliente-prueba"
environment          = "dev"
aws_account_id       = "239452641090"
oidc_role_name       = "GitHubTerraformAccessRole1"
bucket_name          = "terraform-state-cliente-c-dev-239452641090"
dynamodb_table_name  = "terraform-locks-cliente-c-dev-239452641090"
region = "us-east-1"  # O la que corresponda
vpc_cidr_block       = "10.0.0.0/16"
kms_key_id          = "arn:aws:kms:us-east-1:239452641090:key/6ee662b0-3508-418e-a35b-5e9d9ced3222"
vpc_id = "vpc-0123456789abcdef0"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_cidr_blocks   = ["10.0.1.0/24", "10.0.2.0/24"]
private_cidr_blocks  = ["10.0.101.0/24", "10.0.102.0/24"]

