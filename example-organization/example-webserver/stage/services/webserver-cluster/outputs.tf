output "alb_dns_name" {
  description           = "O nome de domínio do balanceador de carga"
  value                 = aws_lb.example.dns_name
}