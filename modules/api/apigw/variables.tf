variable "name" { type = string }
variable "tags" {
  type = map(string)
  default = {}
}
# VPC Link
variable "nlb_arn"  { type = string }
variable "nlb_dns_name" { type = string }
variable "alb_arn"  { type = string }

variable "stage_name"  {
  type = string
  default = "prod"
}
