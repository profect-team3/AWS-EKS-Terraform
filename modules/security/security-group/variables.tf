variable "name" { type = string }
variable "tags"    {
  type = map(string)
  default = {}
}

variable "vpc_id"     { type = string }
variable "vpc_cidr" { type = string }

# variable "service_definitions" {
#   description = "Per-service SG definition (ingress from ALB, and specific egress to DB/Cache)"
#   type = map(object({
#     port         = number
#     egress = list(object({
#       to    = string
#       port  = number
#       proto = optional(string, "tcp")
#     }))
#   }))
# }