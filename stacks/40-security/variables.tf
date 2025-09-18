variable "project"             { type = string }
variable "env"                 { type = string }
variable "region"              { type = string }
variable "tags" {
  type        = map(string)
  default     = {}
}


variable "secret_names" { type = map(string) }
variable "kms_key_arn"  { type = string }

variable "kms_jwt_key_arn" {
  type        = string
  default     = null
}
variable "service_secret_keys"   { type = map(list(string)) }

variable "eks_cluster_name"   { type = string }
variable "namespace"          { type = string }