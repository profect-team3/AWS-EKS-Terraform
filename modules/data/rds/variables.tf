variable "name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

variable "subnet_ids" {type = list(string)}
variable "sg_rds_id" {type = string}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
}

variable "db_name" {
  type    = string
  default = "order_platform"
}

variable "engine_version" {
  type    = string
  default = "16.9" # PostgreSQL 16.9-R1
}

variable "instance_class" {
  type    = string
  default = "db.m5.large"
}

# RDS Proxy 관련
variable "proxy_name" {
  type    = string
  default = "order-rds-proxy"
}

variable "proxy_idle_client_timeout" {
  type    = number
  default = 1800 # 30분
}

variable "proxy_borrow_timeout" {
  type    = number
  default = 120 # 2분
}

variable "proxy_secret_arn_username" {
  type = string
}

variable "proxy_secret_arn_password" {
  type = string
}

variable "proxy_role_arn" {
  type = string
}

