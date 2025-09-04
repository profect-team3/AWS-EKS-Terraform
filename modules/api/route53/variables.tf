# variable "name" { type = string }
# variable "tags" {
#   type = map(string)
#   default = {}
# }
#
# # 퍼블릭 존 생성 또는 기존 존 사용 (둘 중 하나)
# variable "zone_name" {
#   description = "새 퍼블릭 호스티드 존 도메인 (예: example.com). 기존 존 쓰면 null"
#   type        = string
#   default     = null
# }
# variable "existing_hosted_zone_id" {
#   description = "기존 퍼블릭 존 ID (예: Z0123456789ABCDE). 새 존 만들면 null"
#   type        = string
#   default     = null
# }
#
# # API Gateway 커스텀 도메인으로 A/AAAA ALIAS (선택)
# variable "record_name"  {
#   type = string
#   default = null
# }  # 예: api.example.com
# variable "alias_name"   {
#   type = string
#   default = null
# }  # APIGW regional_domain_name
# variable "alias_zone_id"{
#   type = string
#   default = null
# }  # APIGW regional_zone_id
# variable "create_aaaa"  {
#   type = bool
#   default = false
# }
