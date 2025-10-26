######################################################
# 🌐 VPC PRINCIPAL
######################################################
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "FilRouge-VPC"
  }
}

######################################################
# 🧱 SUBNET PUBLIC
######################################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "FilRouge-Subnet"
  }
}

######################################################
# 🌍 INTERNET GATEWAY
######################################################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "FilRouge-Gateway"
  }
}

######################################################
# 🛣️ TABLE DE ROUTAGE
######################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "FilRouge-RouteTable"
  }
}

######################################################
# 🔗 ASSOCIATION ROUTE TABLE / SUBNET
######################################################
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

######################################################
# 🔐 GROUPE DE SÉCURITÉ
######################################################
resource "aws_security_group" "web_sg" {
  name        = "FilRouge-SG"
  description = "Autorise SSH et HTTP"
  vpc_id      = aws_vpc.main.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Sortie libre
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "FilRouge-SG"
  }
}

######################################################
# 💻 INSTANCE EC2 POUR LE DEPLOIEMENT
######################################################
resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  iam_instance_profile = "LabInstanceProfile"  # profil IAM autorisé par le sandbox
  key_name             = "labsuser"            # ✅ clé SSH utilisée pour la connexion

  tags = {
    Name = "FilRouge-EC2"
  }
}


######################################################
# 🗄️ BASE DE DONNÉES RDS (optionnelle)
######################################################
resource "aws_db_instance" "db" {
  allocated_storage   = 20
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  username            = var.db_user
  password            = var.db_pass
  skip_final_snapshot = true
  publicly_accessible = true

  tags = {
    Name = "FilRouge-DB"
  }
}
