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

resource "aws_route_table" "tabla_de_ruta" {
  vpc_id = aws_vpc.vpc_produccion.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Tabla de Ruta"
  }
}


# 5. Asociar la Route Table a la Subnet

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subred_1.id
  route_table_id = aws_route_table.tabla_de_ruta.id
}


# 6. Crear un grupo de seguridad para los puertos 22, 443 y 80

resource "aws_security_group" "permitir_trafico_web" {
  name        = "permitir_trafico_web"
  description = "Permitir tráfico web"
  vpc_id      = aws_vpc.vpc_produccion.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "permitir_trafico_web"
  }
}


# 7. Crear un Network Interface con una IP en la Subnet creada en el paso 3

 resource "aws_network_interface" "Interface_de_red" {
  subnet_id       = aws_subnet.subred_1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.permitir_trafico_web.id]
}


# 8. Asignar una IP elástica al Network Interface creado en el paso 7
# 9. Crear un servidor ubuntu e instalar/habilitar apache2