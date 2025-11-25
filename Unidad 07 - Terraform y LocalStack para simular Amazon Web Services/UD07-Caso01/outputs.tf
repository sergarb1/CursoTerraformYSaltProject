output "archivo_subido" {
  value = aws_s3_object.demo_file.key
}

output "endpoint_localstack" {
  value = "http://localhost:4566"
}
