# locals {
#   name = "${var.project}-${var.env}"
#   tags = merge(var.tags, { Project = var.project, Env = var.env })
# }
#
# resource "aws_wafv2_web_acl" "this" {
#   name        = "${local.name}-webacl"
#   description = "Basic API protection"
#   scope       = "REGIONAL"
#
#   default_action {
#     allow {}
#   }
#
#   dynamic "rule" {
#     for_each = var.enable_common_rule ? [1] : []
#     content {
#       name     = "AWSCommon"
#       priority = 1
#       override_action {
#         none {}
#       }
#       statement {
#         managed_rule_group_statement {
#           name        = "AWSManagedRulesCommonRuleSet"
#           vendor_name = "AWS"
#         }
#       }
#       visibility_config {
#         cloudwatch_metrics_enabled = true
#         metric_name                = "${local.name}-AWSCommon"
#         sampled_requests_enabled   = true
#       }
#     }
#   }
#
#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "${local.name}-webacl"
#     sampled_requests_enabled   = true
#   }
#
#   tags = local.tags
# }
