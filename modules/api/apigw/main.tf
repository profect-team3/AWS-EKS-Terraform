# REST API
resource "aws_api_gateway_rest_api" "this" {
  name = "${var.name}-apigw"
  endpoint_configuration { types = ["REGIONAL"] }
  tags = var.tags
}

# root "/"
data "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  path        = "/"
}

# {proxy+} 리소스
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = data.aws_api_gateway_resource.root.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# VPC Link
resource "aws_api_gateway_vpc_link" "this" {
  name        = "${var.name}-vpclink"
  target_arns = var.nlb_arn
  tags        = var.tags
}

# 프록시 통합 -> http://<NLB_DNS>:80/{proxy}
resource "aws_api_gateway_integration" "proxy_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  uri                = "http://${var.nlb_dns_name}:80/{proxy}"
  connection_type    = "VPC_LINK"
  connection_id      = aws_api_gateway_vpc_link.this.id
  passthrough_behavior = "WHEN_NO_MATCH"
}

# (선택) 루트 "/"도 프록시
resource "aws_api_gateway_method" "root_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = data.aws_api_gateway_resource.root.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = data.aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.root_any.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${var.nlb_dns_name}:80/"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
  passthrough_behavior    = "WHEN_NO_MATCH"
}

# 배포 & 스테이지
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy_any.id,
      aws_api_gateway_integration.proxy_any.id,
      aws_api_gateway_method.root_any.id,
      aws_api_gateway_integration.root_any.id,
      var.nlb_arn,
      var.alb_arn
    ]))
  }
  depends_on = [
    aws_api_gateway_integration.proxy_any,
    aws_api_gateway_integration.root_any
  ]
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name
  tags          = var.tags
}

