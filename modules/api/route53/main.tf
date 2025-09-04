# # 퍼블릭 호스티드 존 생성 (기존 존 없고 zone_name 있을 때만)
# resource "aws_route53_zone" "public" {
#   count   = var.existing_hosted_zone_id == null && var.zone_name != null ? 1 : 0
#   name    = var.zone_name
#   comment = "${var.name} public zone"
#   tags    = var.tags
# }
#
# # 사용할 Hosted Zone ID (기존 or 새로 만든 것)
# locals {
#   hosted_zone_id = coalesce(var.existing_hosted_zone_id, try(aws_route53_zone.public[0].zone_id, null))
# }
#
# # ALIAS 레코드 생성 조건
# locals {
#   create_alias = (
#   var.record_name  != null &&
#   var.alias_zone_id != null &&
#   local.hosted_zone_id != null
#   )
# }
#
# resource "aws_route53_record" "a_alias" {
#   count   = local.create_alias ? 1 : 0
#   zone_id = local.hosted_zone_id
#   name    = var.record_name
#   type    = "A"
#
#   alias {
#     name                   = var.alias_name
#     zone_id                = var.alias_zone_id
#     evaluate_target_health = true
#   }
# }
#
# resource "aws_route53_record" "aaaa_alias" {
#   count   = local.create_alias && var.create_aaaa ? 1 : 0
#   zone_id = local.hosted_zone_id
#   name    = var.record_name
#   type    = "AAAA"
#
#   alias {
#     name                   = var.alias_name
#     zone_id                = var.alias_zone_id
#     evaluate_target_health = true
#   }
# }