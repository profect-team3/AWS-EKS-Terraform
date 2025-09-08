variable "project"             { type = string }
variable "env"                 { type = string }
variable "region"              { type = string }
variable "tags" {
  type        = map(string)
  default     = {}
}

# ecr
variable "image_mutability" {
  type = string
  default = "MUTABLE"
}
# variable "scan_on_push"     {
#   type = bool
#   default = true
# }
# variable "encryption_type"  {
#   type = string
#   default = "AES256"
# }
# variable "kms_key_arn"      {
#   type = string
#   default = null
# }

variable "keep_tag_prefixes"{
  type    = list(string)
  default = ["latest"]
}
variable "keep_any_last"    {
  type = number
  default = 5
}

# service
variable "service_definitions" {
  type    = list(string)
}
