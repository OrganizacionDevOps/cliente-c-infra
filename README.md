Este repositorio contiene la infraestructura declarativa específica de un cliente (cliente-X) usando módulos remotos centralizados en el repositorio base: OrganizacionDevOps/OptimizApp_Infraestrucutra_Modular
🧩 Estructura del Proyecto Cliente
cliente-X-infra/
├── main.tf
├── backend.tf
├── vpc.tf
├── terraform.tfvars
├── variables.tf
└── .github/workflows/terraform.yml
________________________________________

¿Por qué y para qué se usó el bootstrap.sh?
🎯 Propósito del script bootstrap.sh
El script bootstrap.sh se usó para generar automáticamente el backend remoto de Terraform antes de cualquier otra acción, porque sin este paso, el CLI de Terraform no puede inicializarse correctamente.
________________________________________
🔍 ¿Por qué fue necesario este enfoque?
1. Terraform necesita el backend antes de hacer cualquier cosa
Terraform no puede hacer init, plan, validate, ni apply sin saber:
•	Dónde guardar su state (.tfstate)
•	Cómo bloquearlo (DynamoDB)
•	Y con qué credenciales acceder a ese backend
💡 Esto se define en el módulo backend, el cual:
•	No se puede cargar hasta que exista un main.tf que lo refiera
•	Y necesita un archivo terraform.tfvars con los valores concretos
________________________________________
2. No era viable mantener esos archivos escritos a mano
Escribir manualmente main.tf y terraform.tfvars en cada repositorio cliente (uno por cliente y ambiente) rompía con el objetivo de automatización modular.
Así que se decidió:
✅ Crear un script reutilizable (bootstrap.sh) que genere esos archivos con los valores exactos para el cliente.
________________________________________
3. El backend debe estar disponible antes del pipeline de Terraform
Por eso el script debe ejecutarse antes de terraform init, ya sea:
•	Manualmente en el primer commit de setup, o
•	Automáticamente desde un pipeline de bootstrap
Si no se ejecuta primero, todo el workflow falla con errores como:
yaml
CopiarEditar
Error: No backend configured
o
yaml
CopiarEditar
Error: No terraform.tfvars file found

¿Qué es el script bootstrap.sh?
El script bootstrap.sh es un generador automatizado que prepara los archivos Terraform mínimos requeridos en el repositorio cliente, con el fin de inicializar correctamente la infraestructura desde módulos remotos (ubicados en el repositorio base infra-modular).
📁 Archivos que genera:
1.	main.tf: Define el llamado al módulo backend (remoto).
2.	terraform.tfvars: Contiene los valores específicos del cliente.
3.	Crea un directorio de trabajo temporal (bootstrap-temp-CLIENTE-ENV).
________________________________________


¿Qué errores surgieron si no se ejecutaba primero?
1.	Faltaba el terraform.tfvars:
Error: Failed to read variables file
2.	El módulo backend no podía inicializarse:
Error: Module not found
3.	No se podía autenticar en AWS porque no había rol ni región:
javascript
Error: aws-region not defined

Flujo completo del uso de bootstrap.sh


 




🔁 Flujo del pipeline de bootstrap
📜 Workflow YAML (resumido)
name: Bootstrap Infraestructura Cliente

on:
  workflow_dispatch:

jobs:
  bootstrap:
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash

    steps:
      - name: Checkout repositorio
        uses: actions/checkout@v4

      - name: Dar permisos al script
        run: chmod +x ./bootstrap.sh

      - name: Ejecutar script bootstrap
        run: ./bootstrap.sh
________________________________________
🧪 ¿Qué hace el script bootstrap.sh paso a paso?
#!/bin/bash

echo "🧹 Limpiando residuos anteriores..."
rm -rf bootstrap-temp-*

echo "📂 Creando carpeta de trabajo: bootstrap-temp-${CLIENT_NAME}-${ENVIRONMENT}"
mkdir -p bootstrap-temp-${CLIENT_NAME}-${ENVIRONMENT}

echo "🛠️ Generando main.tf..."
cat <<EOF > bootstrap-temp-${CLIENT_NAME}-${ENVIRONMENT}/main.tf
module "backend" {
  source              = "git::https://github.com/OrganizacionDevOps/OptimizApp_Infraestrucutra_Modular.git//modules/backend/aws?ref=main"
  aws_account_id      = var.aws_account_id
  oidc_role_name      = var.oidc_role_name
  bucket_name         = var.bucket_name
  dynamodb_table_name = var.dynamodb_table_name
  tags = {
    Client      = var.client_name
    Environment = var.environment
  }
}
EOF

echo "📄 Generando terraform.tfvars..."
cat <<EOF > bootstrap-temp-${CLIENT_NAME}-${ENVIRONMENT}/terraform.tfvars
client_name         = "${CLIENT_NAME}"
environment         = "${ENVIRONMENT}"
aws_account_id      = "${AWS_ACCOUNT_ID}"
oidc_role_name      = "${OIDC_ROLE_NAME}"
bucket_name         = "${BUCKET_NAME}"
dynamodb_table_name = "${DYNAMODB_TABLE_NAME}"
region              = "${REGION}"
EOF
________________________________________
🚨 Errores comunes encontrados
Error	Causa	Solución
Permission denied (publickey)	El módulo remoto era llamado por ssh://... sin credenciales configuradas	Se cambió a https:// + configuración de PAT
terraform.tfvars no existe	El script generaba los archivos en una carpeta temporal no usada por el pipeline	Se ajustó el working-directory o se copiaron los archivos al raíz
Invalid argument name o multi-line string	Errores de sintaxis por comillas incorrectas o EOF mal formateado	Se revisaron las comillas y uso correcto de cat <<EOF > archivo
Unsupported argument	Variables no definidas en el módulo base	Se revisó el variables.tf del módulo base y se alinearon los argumentos
________________________________________
🧬 ¿Por qué es necesario este script?
1.	Estandariza la creación del entorno Terraform por cliente.
2.	Evita errores manuales creando automáticamente los archivos.
3.	Permite bootstrap automático desde pipelines o manual (workflow_dispatch).
4.	Es clave para iniciar terraform init correctamente.
________________________________________
✅ Buenas prácticas aplicadas
•	El script se hizo idempotente (borra residuos previos).
•	Se usaron nombres dinámicos basados en variables de entorno (CLIENT_NAME, ENVIRONMENT).
•	Se validó la existencia de .env para cargar secretos si no están definidos como secrets en GitHub.
•	Se integró correctamente al flujo de GitHub Actions.
🔗 Conexión con el Repositorio Base

 ¿Qué es un PAT?
Un Personal Access Token (PAT) es un token que funciona como una contraseña para autenticarte con GitHub desde la línea de comandos o CI/CD (como GitHub Actions).
________________________________________
1. Crear un PAT desde GitHub
1.	Ve a GitHub → tu avatar (arriba a la derecha) → Settings.
2.	En el menú lateral izquierdo: Developer settings → Personal access tokens.
3.	Haz clic en Tokens (classic) → luego en Generate new token (classic).
4.	Configura el token:
	Note: escribe algo como Terraform Module Access.
	Expiration: 90 días o "No expiration".
	Scopes (permisos):repo (esto incluye repo:read, necesario para clonar módulos privados).
5.	Haz clic en Generate token.
6.	Copia el token y guárdalo en un lugar seguro. Solo se muestra una vez.
________________________________________
2. Guardar el PAT como secreto en el repositorio cliente
1.	Ve al repositorio cliente en GitHub.
2.	Haz clic en Settings → Secrets and variables → Actions → New repository secret.
3.	Llena los campos:
•	Name: MODULAR_REPO_PAT
•	Value: pega el PAT que generaste.
4.	Guarda.
________________________________________
 3. Usar el PAT en tu workflow (.github/workflows/terraform.yml)
Incluye esta línea antes de ejecutar Terraform para que GitHub Actions pueda clonar el repo modular con el token:
- name: 🔐 Configurar acceso a módulos privados con PAT
  run: |
    git config --global url."https://${{ secrets.MODULAR_REPO_PAT }}@github.com/".insteadOf "https://github.com/"
Esto reemplaza todas las URLs que usan https://github.com/ por una versión autenticada con tu PAT.
________________________________________
4. Usar el módulo desde el repositorio base
En tu módulo (ej. vpc.tf):
module "vpc" {
  source     = "git::https://github.com/OrganizacionDevOps/OptimizApp_Infraestrucutra_Modular.git//modules/networking/vpc?ref=main"
  ...
}
Gracias a la configuración de git config, Terraform podrá clonar ese módulo privado automáticamente con el PAT.

 ¿Por qué se eligió usar un PAT?
La decisión de usar HTTPS + PAT (en lugar de SSH o tokens de GitHub App) fue por factores prácticos y organizacionales específicos, resumidos a continuación:
________________________________________
1. Ambos repos están en la misma organización privada
Cuando el repositorio cliente y el repositorio de módulos están en la misma organización, GitHub permite usar un PAT con permisos repo para acceder a ambos sin configurar llaves SSH.
Esto:
•	evita configuraciones adicionales de llaves privadas/SSH.
•	es más directo y portable en GitHub Actions.
•	funciona bien con git::https://... en Terraform.
________________________________________
2. Porque OIDC no sirve para clonar repos privados
Aunque usas OIDC (OpenID Connect) para asumir roles en AWS, no sirve para autenticar contra GitHub. Entonces, si el repositorio base es privado, Terraform necesita un método alternativo para acceder a él. Y aquí es donde entra el PAT.
________________________________________
 3. Porque SSH requiere configurar claves privadas seguras
Conexiones SSH implican:
•	Generar un par de claves (privada/pública).
•	Agregar la clave pública a la organización o al usuario como Deploy Key o SSH Key.
•	Agregar la clave privada como secreto en GitHub Actions.
Esto aumenta la complejidad, especialmente si hay múltiples clientes/repositorios.
________________________________________
4. Porque PAT es más fácil de escalar en entornos multi-cliente
En tu caso, donde:
•	Tienes un repositorio base central (infra-modular).
•	Y creas un repositorio cliente por cada cliente (cliente-a-infra, cliente-b-infra, etc.).
El uso de un único PAT compartido o uno por cliente como MODULAR_REPO_PAT:
•	Centraliza el control de acceso.
•	Permite al equipo usar los módulos sin tocar configuración de red/SSH.

La conexión entre el repositorio cliente y el repositorio base en Terraform se logra usando la instrucción source dentro de un bloque module, haciendo referencia a un módulo remoto ubicado en un subdirectorio del repositorio base. Esta es una funcionalidad nativa de Terraform y permite que desde el repo cliente reutilices módulos versionados sin duplicar código.

Requisitos para que funcione
1.	El módulo en el repo base debe tener definido un variables.tf con las mismas variables que le vas a pasar.
2.	El repo cliente debe tener un archivo .tfvars o variables definidas para alimentar al módulo.
3.	El ref=main puede ser reemplazado por una etiqueta (ej. ?ref=v1.0.0) para mantener versiones estables.
4.	Si usas GitHub Actions, asegúrate de que se haya configurado el acceso a repos privados antes de terraform init.

Comportamiento en ejecución
Cuando corres:
TERRAFORM INIT
Terraform:
•	Clona temporalmente el módulo desde GitHub al directorio .terraform/modules/vpc
•	Lee el código fuente del módulo
•	Valida las variables necesarias y las que se pasaron
•	Prepara todo para aplicar o planificar




module "vpc" {
  source        = "git::https://github.com/OrganizacionDevOps/OptimizApp_Infraestrucutra_Modular.git//modules/networking/vpc?ref=main"
  vpc_name      = "${var.client_name}-${var.environment}-vpc"
  cidr_block    = var.vpc_cidr_block
  kms_key_id    = var.kms_key_id
  tags = {
    Client      = var.client_name
    Environment = var.environment
  }
}
Igualmente, se incluye el módulo de backend:

module "backend" {
  source              = "git::https://github.com/OrganizacionDevOps/OptimizApp_Infraestrucutra_Modular.git//modules/backend/aws?ref=main"
  aws_account_id      = var.aws_account_id
  oidc_role_name      = var.oidc_role_name
  bucket_name         = var.bucket_name
  dynamodb_table_name = var.dynamodb_table_name
  region              = var.region
  tags = {
    Client      = var.client_name
    Environment = var.environment
  }
}
________________________________________
Errores Encontrados y Resolución
 1. Error: Missing required argument: region
•	Motivo: El módulo backend requiere explícitamente region, pero no estaba definido en el terraform.tfvars
•	Solución: Se añadió en variables.tf y terraform.tfvars.
# variables.tf
variable "region" {
  description = "Región de AWS"
  type        = string
}


# terraform.tfvars
region = "us-east-1"
________________________________________
2. Error: Unsupported argument "client_name" o "enable_nat"
•	Motivo: Se intentaron pasar variables al módulo vpc que no eran definidas como argumentos válidos en su variables.tf (del repositorio base).
•	Solución: Se eliminaron argumentos innecesarios (client_name, enable_nat, etc.) y se ajustó el uso de tags y cidr_block.
________________________________________
3. Error: Duplicate module call "vpc"
•	Motivo: Había una invocación de módulo duplicada (una en vpc.tf, otra en variables.tf).
•	Solución: Se eliminó cualquier invocación incorrecta o duplicada desde variables.tf, que no debe contener llamadas a módulos.
________________________________________
4. Error de Clonación por SSH: Permission denied (publickey)
•	Motivo: El repo base era privado y no se configuró correctamente el acceso en GitHub Actions.
•	Soluciones aplicadas:
o	Se configuró correctamente una clave privada SSH o un PAT:
Opción A: SSH (más segura)
- name: Configurar acceso con SSH
  run: |
    mkdir -p ~/.ssh
    echo "${{ secrets.SSH_PRIVATE_KEY_MODULAR }}" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    ssh-keyscan github.com >> ~/.ssh/known_hosts
Opción B: PAT (más fácil de configurar) -en uso 
- name: Configurar acceso con PAT
  run: |
    git config --global url."https://${{ secrets.MODULAR_REPO_PAT }}@github.com/".insteadOf "https://github.com/"
________________________________________
Pipeline (GitHub Actions)

El flujo del pipeline es el siguiente:

name: Terraform Cliente 	      Nombre del workflow. Aparece en la UI de GitHub Actions.

on:
  push:
    paths:
      - 'clients/cliente-x/infra/**'	
  pull_request:
  workflow_dispatch:


jobs:
  terraform:


   
 runs-on: ubuntu-latest


    env:
      REGION: ${{ secrets.REGION }}
      AWS_REGION: ${{ secrets.REGION }}
      AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
      OIDC_ROLE_NAME: ${{ secrets.OIDC_ROLE_NAME }}
      CLIENT_NAME: ${{ secrets.CLIENT_NAME }}
      ENVIRONMENT: ${{ secrets.ENVIRONMENT }}
  

  steps:
      - uses: actions/checkout@v4



      - name: Cargar variables desde .env
        run: |
          if [ -f .env ]; then
            export $(grep -v '^#' .env | xargs)
          fi




      - name: Configurar credenciales AWS vía OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ env.AWS_ACCOUNT_ID }}:role/${{ env.OIDC_ROLE_NAME }}
          aws-region: ${{ env.REGION }}






      - name: Instalar Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.7




      - name: Terraform Init
        run: terraform init





      - name: Terraform Validate
        run: terraform validate





      - name: Terraform Plan
        run: terraform plan -var-file="terraform.tfvars"




________________________________________
🧪 Comandos Ejecutados
Durante el debugging y pruebas se usaron comandos como:
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform fmt -recursive
________________________________________
🧠 Consideraciones Finales
•	Todos los módulos remotos deben tener inputs alineados con las variables declaradas en el cliente.
•	El main.tf puede actuar como punto de entrada o agrupador de módulos si se desea centralizar todo.
•	Es fundamental mantener consistencia entre los nombres y tipos de variables entre ambos repos.

