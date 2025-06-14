provider "aws" {
  profile = "mi_perfil"
  region  = "us-east-1"
}



# 1. Crear una VPC

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


# 2. Crear un Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_produccion.id
}


# 3. Crear una Subnet

resource "aws_subnet" "subred_1" {
  vpc_id     = aws_vpc.vpc_produccion.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet_1"
  }
}


# 4. Crear una Route Table
# 5. Asociar la Route Table a la Subnet
# 6. Crear un grupo de seguridad para los puertos 22, 443 y 80
# 7. Crear un Network Interface con una IP en la Subnet creada en el paso 3
# 8. Asignar una IP elástica al Network Interface creado en el paso 7
# 9. Crear un servidor ubuntu e instalar/habilitar apache2