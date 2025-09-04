variable "name" { type = string }
variable "tags" {
  type = map(string)
  default = {}
}


variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }

variable "listener_ports" {
  type    = list(number)
  default = []
}
variable "alb_arn" { type = string }