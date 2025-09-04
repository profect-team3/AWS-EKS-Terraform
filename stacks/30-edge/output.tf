output "nlb_dns"     { value = module.nlb.nlb_dns_name }
output "alb_dns"     { value = module.alb.alb_dns_name }
output "alb_tgs"     { value = module.alb.target_group_arns }
