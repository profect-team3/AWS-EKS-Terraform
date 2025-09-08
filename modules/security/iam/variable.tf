variable "name" { type = string }
variable "region" { type = string }
variable "tags"    {
  type = map(string)
  default = {}
}

variable "eks_cluster_name"   { type = string }   # EKS 클러스터 이름
variable "namespace"          { type = string }   # ex: msa-test
variable "kms_key_arn"        { type = string }   # KMS는 필수
variable "secret_names"       { type = map(string) }
