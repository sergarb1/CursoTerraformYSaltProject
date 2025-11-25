terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"     # Claves dummy
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true        # 👈 IMPORTANTE: evita la validación de cuenta real
  s3_use_path_style           = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}


# Crear un bucket S3 simulado
resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.bucket_name
}

# Subir un objeto al bucket
resource "aws_s3_object" "demo_file" {
  bucket = aws_s3_bucket.demo_bucket.id
  key    = "hola.txt"
  content = "¡Hola desde Terraform con LocalStack!"
}

output "bucket_name" {
  value = aws_s3_bucket.demo_bucket.bucket
}
