
# 3) API Gateway (REST) + VPC Link → NLB
# module "apigw" {
#   source        = "../../modules/edge/apigw"
#   name          = local.name
#   nlb_arn       = module.nlb.nlb_arn
#   nlb_dns_name  = module.nlb.nlb_dns_name
#   nlb_port      = 80
#   paths         = var.apigw_paths
#   stage_name    = "prod"
#   description   = "Edge REST API"
#   domain_name   = var.edge_domain
#   certificate_arn = var.acm_certificate_arn
#   tags          = var.tags
# }

# 4) Route53 → APIGW 커스텀 도메인 Alias
# module "route53" {
#   source         = "../../modules/edge/route53"
#   name           = local.name
#   existing_hosted_zone_id = var.route53_zone_id
#   zone_name      = null
#   record_name    = var.edge_domain
#   alias_name     = module.apigw.domain_regional_domain_name
#   alias_zone_id  = module.apigw.domain_regional_zone_id
#   create_aaaa    = true
#   tags = local.tags
# }