######################################################
# VARIABLES GLOBALES
######################################################
variable "region" {
  description = "Région AWS"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR du Subnet"
  type        = string
}

variable "ami_id" {
  description = "AMI de l'instance EC2"
  type        = string
}

variable "instance_type" {
  description = "Type d’instance EC2"
  type        = string
}

variable "db_user" {
  description = "Utilisateur de la base RDS"
  type        = string
}

variable "db_pass" {
  description = "Mot de passe de la base RDS"
  type        = string
}
