variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0" # Recomiendo segmentar la IP con /32 a tu ip propia, sino dejarla asi abierta porfa
}

variable "docker_image" {
  type    = string
  default = "manveira/consulting:v1"
}

variable "ssh_key_name" {
  type        = string
  description = "Nombre del par de claves SSH"
  default     = "key-pair-manve2"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Ruta al archivo de clave pública SSH"
  default     = "~/.ssh/id_rsa.pub"
}