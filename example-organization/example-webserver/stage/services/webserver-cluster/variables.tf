variable "scaling_ec2" {
  description           = "Configuracao de auto-scaling dos ec2."
  type                  = map(number)
  default               = {
    min_size = 2
    max_size = 10
  }
}

variable "server_port" {
  description           = "A porta que o servidor usará para solicitações HTTP"
  type                  = number
  default               = 8080
}