provider "aws" {
  profile = "mi_perfil"
  region  = "us-east-1"
}



# 1. Crear una VPC

resource "aws_vpc" "vpc_produccion" {
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
    gateway_id = aws_internet_gateway.gw.id
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
  description = "Permitir trafico web"
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


# 7. Crear un Network Interface con una IP en la subred creada en el paso 3

 resource "aws_network_interface" "Interface_de_red" {
  subnet_id       = aws_subnet.subred_1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.permitir_trafico_web.id]
}


# 8. Asignar una IP elástica al Network Interface creado en el paso 7

resource "aws_eip" "IP_elastica" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.Interface_de_red.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.gw ]
}

output "servidor_IP_publica" {
  value = aws_eip.IP_elastica.public_ip
  
}


# 9. Crear un servidor ubuntu e instalar/habilitar apache2

resource "aws_key_pair" "mi_clave" {
  key_name   = "mi_clave_aws"
  public_key = file("mi_clave_aws.pub")
}

resource "aws_instance" "web" {
  ami = "ami-0a9115d9e297c6103"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = aws_key_pair.mi_clave.key_name

  network_interface {
    network_interface_id = aws_network_interface.Interface_de_red.id
    device_index         = 0
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              systemctl enable apache2
              systemctl start apache2
              bash -c 'echo "<h1>¡Hola, mundo!</h1>" > /var/www/html/index.html'
              EOF

  tags = {
    Name = "Servidor_Web"
  }
}