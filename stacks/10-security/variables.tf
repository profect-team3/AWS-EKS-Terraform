variable "project"             { type = string }
variable "env"                 { type = string }
variable "region"              { type = string }
variable "tags" {
  type        = map(string)
  default     = {}
}

variable "account_id"              { type = string }

variable "service_definitions" {
  description = "Per-service SG definition (ingress from ALB, and specific egress to DB/Cache)"
  type = map(object({
    port         = number
    egress = list(object({
      to    = string
      port  = number
      proto = optional(string, "tcp")
    }))
  }))
}

variable "secret_names" { type = map(string) }
variable "kms_key_arn"  { type = string }

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "eks_cluster_name"   { type = string }
variable "namespace"          { type = string }