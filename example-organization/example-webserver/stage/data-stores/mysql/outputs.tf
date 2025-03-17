output "address" {
  description   = "Conecte-se ao banco de dados neste endpoint"
  value         = aws_db_instance.example.address
}

output "port" {
  description   = "A porta em que o banco de dados está escutando"
  value         = aws_db_instance.example.port
}