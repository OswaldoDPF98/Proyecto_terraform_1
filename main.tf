provider "aws" {
  profile = "mi_perfil"
  region  = "us-east-1"
}



# 1. Crear una VPC

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


# 2. Crear un Internet Gateway
# 3. Crear una Subnet
# 4. Crear una Route Table
# 5. Asociar la Route Table a la Subnet
# 6. Crear un grupo de seguridad para los puertos 22, 443 y 80
# 7. Crear un Network Interface con una IP en la Subnet creada en el paso 3
# 8. Asignar una IP elástica al Network Interface creado en el paso 7
# 9. Crear un servidor ubuntu e instalar/habilitar apache2