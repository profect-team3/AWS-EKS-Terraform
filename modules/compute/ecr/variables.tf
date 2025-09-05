variable "name" { type = string }
variable "tags" {
  type = map(string)
  default = {}
}

variable "repositories" {
  description = "생성할 ECR 리포지토리 이름 목록 (예: [\"user\", \"store\", ...])"
  type        = list(string)
}

variable "image_mutability" {
  type    = string
  default = "MUTABLE" # or "IMMUTABLE"
}
# variable "scan_on_push" {
#   type    = bool
#   default = true
# }
# variable "encryption_type" {
#   type    = string
#   default = "AES256" # or "KMS"
# }
# variable "kms_key_arn" {
#   type    = string
#   default = null
# }

# 태그 prefix 목록(서비스 이름 등) - 각 prefix에 대해 최소 1개 보존 (예: latest, api, auth 등)
variable "keep_tag_prefixes" {
  type    = list(string)
  default = ["latest"]
}

# any 이미지 최근 N개 보존
variable "keep_any_last" {
  type    = number
  default = 10
}