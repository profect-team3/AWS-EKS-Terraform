
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.subnet_ids
  tags               = var.tags
}

# 서비스별 Target Group (ECS에서 attach)
resource "aws_lb_target_group" "svc" {
  for_each    = var.services

  name        = substr("${var.name}-${each.key}-tg", 0, 32)
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    path                = var.health_check_path
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Service = each.key
  })
}

# 고정 200
resource "aws_lb_listener_rule" "http_root_ok" {
  listener_arn = aws_lb_listener.http.arn
  # 다른 규칙들과 겹치지 않도록 충분히 큰 우선순위(가장 뒤)로 둡니다.
  priority     = 10000

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# https
# resource "aws_lb_listener_rule" "https_root_ok" {
#   count        = var.alb_certificate_arn != null ? 1 : 0
#   listener_arn = aws_lb_listener.https[0].arn
#   priority     = 10000
#   action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "OK"
#       status_code  = "200"
#     }
#   }
#   condition { path_pattern { values = ["/"] } }
# }

# HTTP(80) 리스너: 기본은 404, 규칙으로 경로 라우팅
# 추후에 443 사용시에는 default_action.type="redirect"로 443에 연결되도록 수정
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# HTTPS(443) 리스너: 인증서 제공 시에만 생성
# resource "aws_lb_listener" "https" {
#   count             = var.alb_certificate_arn != null ? 1 : 0
#   load_balancer_arn = aws_lb.this.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.alb_certificate_arn
#
#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Not Found"
#       status_code  = "404"
#     }
#   }
# }

# 경로 기반 라우팅 규칙 (HTTP 80)
resource "aws_lb_listener_rule" "http_paths" {
  for_each     = var.services

  listener_arn = aws_lb_listener.http.arn
  # priority     = 100 + index(keys(var.services), each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.svc[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.paths
    }
  }
}

# HTTPS(443) 경로 라우팅 규칙 (인증서 있을 때만)
# resource "aws_lb_listener_rule" "https_paths" {
#   for_each     = var.alb_certificate_arn != null ? var.services : {}
#   listener_arn = aws_lb_listener.https[0].arn
#   priority     = 200 + index(local.service_keys, each.key)
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.svc[each.key].arn
#   }
#
#   condition {
#     path_pattern { values = each.value.paths }
#   }
# }