variable "name" { type = string }
variable "region"  { type = string }
variable "tags"    {
  type = map(string)
  default = {}
}

variable "vpc_id"     { type = string }
variable "subnet_ids" { type = list(string) }
variable "private_route_table_ids" { type = list(string) }

