# output "hosted_zone_id" { value = local.hosted_zone_id }
# output "zone_name"      { value = try(aws_route53_zone.public[0].name, null) }
# output "name_servers"   { value = try(aws_route53_zone.public[0].name_servers, null) } # 새 퍼블릭 존일 때
# output "record_fqdn"    { value = try(aws_route53_record.a_alias[0].fqdn, null) }
