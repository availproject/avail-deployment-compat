resource "aws_lb_target_group" "avail_full_node_ws" {
  name        = "full-node-ws"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.devnet.id
  port        = var.avail_ws_port
}
resource "aws_lb_target_group_attachment" "avail_full_node_ws" {
  count            = length(aws_instance.full_node)
  target_group_arn = aws_lb_target_group.avail_full_node_ws.arn
  target_id        = element(aws_instance.full_node, count.index).id
  port             = var.avail_ws_port
}
resource "aws_lb_target_group" "avail_full_node_rpc" {
  name        = "full-node-rpc"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.devnet.id
  port        = var.avail_rpc_port
}
resource "aws_lb_target_group_attachment" "avail_full_node_rpc" {
  count            = length(aws_instance.full_node)
  target_group_arn = aws_lb_target_group.avail_full_node_rpc.arn
  target_id        = element(aws_instance.full_node, count.index).id
  port             = var.avail_rpc_port
}
resource "aws_lb_target_group" "avail_explorer_http" {
  name        = "explorer-http"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.devnet.id
  port        = var.avail_explorer_port
}
resource "aws_lb_target_group_attachment" "avail_explorer_http" {
  count            = length(aws_instance.explorer)
  target_group_arn = aws_lb_target_group.avail_explorer_http.arn
  target_id        = element(aws_instance.explorer, count.index).id
  port             = var.avail_explorer_port
}

resource "aws_lb" "explorer_rpc" {
  name               = "avail-alb-explorer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_https_explorer.id, aws_default_security_group.default.id]
  internal           = true
  subnets            = [for subnet in aws_subnet.devnet_private : subnet.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "avail_explorer_80" {
  load_balancer_arn = aws_lb.explorer_rpc.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "avail_explorer_443" {
  load_balancer_arn = aws_lb.explorer_rpc.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.avail_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.avail_explorer_http.arn
  }
}



resource "aws_lb_listener_rule" "avail_ws" {
  listener_arn = aws_lb_listener.avail_explorer_443.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.avail_full_node_ws.arn
  }

  condition {
    path_pattern {
      values = ["/ws"]
    }
  }

}
resource "aws_lb_listener_rule" "avail_rpc" {
  listener_arn = aws_lb_listener.avail_explorer_443.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.avail_full_node_rpc.arn
  }

  condition {
    path_pattern {
      values = ["/rpc"]
    }
  }

}
