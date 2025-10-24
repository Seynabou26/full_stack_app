######################################################
# 🌍 PROVIDER AWS
######################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
  required_version = ">= 1.5.0"
}

# 🔧 Provider AWS : connexion à ton compte
provider "aws" {
  region = var.region  # Définie dans variables.tf (ex: "us-west-2")
}
