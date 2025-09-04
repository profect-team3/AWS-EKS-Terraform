output "api_id"        { value = aws_api_gateway_rest_api.this.id }
# output "stage_name"    { value = aws_api_gateway_stage.this.stage_name }
# output "stage_arn"     { value = aws_api_gateway_stage.this.arn }
# output "invoke_url"    {
#   value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.this.stage_name}"
# }
# output "vpc_link_id"   { value = aws_api_gateway_vpc_link.this.id }
