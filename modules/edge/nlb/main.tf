locals {
  listener_ports_map = { for p in var.listener_ports : tostring(p) => p }
}

resource "aws_lb" "this" {
  name               = "${var.name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  tags               = var.tags
}

resource "aws_lb_target_group" "nlb_to_alb" {
  for_each    = local.listener_ports_map
  name        = "${var.name}-nlb-tg-${each.key}"
  port        = each.value
  protocol    = "TCP"
  target_type = "alb"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_lb_listener" "tcp" {
  for_each    = local.listener_ports_map
  load_balancer_arn = aws_lb.this.arn
  port        = each.value
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_to_alb[each.key].arn
  }
}

# /actuator/health
resource "aws_lb_target_group_attachment" "attach_alb" {
  for_each         = local.listener_ports_map
  target_group_arn = aws_lb_target_group.nlb_to_alb[each.key].arn
  target_id        = var.alb_arn
  port             = each.value
}
