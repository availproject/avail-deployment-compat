resource "aws_lb" "avail_nodes" {
  name               = "avail-lb"
  load_balancer_type = "network"
  internal           = false
  subnets            = [for subnet in aws_subnet.devnet_public : subnet.id]
}
resource "aws_lb_target_group" "avail_full_node" {
  count       = length(aws_instance.full_node)
  name        = format("full-node-%02d", count.index + 1)
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.devnet.id
  port        = element(aws_instance.full_node, count.index).tags.AvailPort
}
resource "aws_lb_target_group" "avail_validator" {
  count       = length(aws_instance.validator)
  name        = format("validator-%02d", count.index + 1)
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.devnet.id
  port        = element(aws_instance.validator, count.index).tags.AvailPort
}
resource "aws_lb_target_group" "avail_light_client" {
  count       = length(aws_instance.light_client)
  name        = format("light-client-%02d", count.index + 1)
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.devnet.id
  port        = element(aws_instance.light_client, count.index).tags.LightPort
}

resource "aws_lb_target_group_attachment" "avail_full_node" {
  count            = length(aws_instance.full_node)
  target_group_arn = element(aws_lb_target_group.avail_full_node, count.index).arn
  target_id        = element(aws_instance.full_node, count.index).id
  port             = element(aws_instance.full_node, count.index).tags.AvailPort
}

resource "aws_lb_target_group_attachment" "avail_validator" {
  count            = length(aws_instance.validator)
  target_group_arn = element(aws_lb_target_group.avail_validator, count.index).arn
  target_id        = element(aws_instance.validator, count.index).id
  port             = element(aws_instance.validator, count.index).tags.AvailPort
}
resource "aws_lb_target_group_attachment" "avail_light_client" {
  count            = length(aws_instance.light_client)
  target_group_arn = element(aws_lb_target_group.avail_light_client, count.index).arn
  target_id        = element(aws_instance.light_client, count.index).id
  port             = element(aws_instance.light_client, count.index).tags.LightPort
}


resource "aws_lb_listener" "avail_full_node" {
  count             = length(aws_instance.full_node)
  load_balancer_arn = aws_lb.avail_nodes.arn
  port              = element(aws_instance.full_node, count.index).tags.AvailPort
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.avail_full_node, count.index).arn
  }
}
resource "aws_lb_listener" "avail_validator" {
  count             = length(aws_instance.validator)
  load_balancer_arn = aws_lb.avail_nodes.arn
  port              = element(aws_instance.validator, count.index).tags.AvailPort
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.avail_validator, count.index).arn
  }
}
resource "aws_lb_listener" "avail_light_client" {
  count             = length(aws_instance.light_client)
  load_balancer_arn = aws_lb.avail_nodes.arn
  port              = element(aws_instance.light_client, count.index).tags.LightPort
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.avail_light_client, count.index).arn
  }
}


resource "aws_lb_target_group" "explorer_rpc" {
  name        = "avail-alb-target"
  port        = 443
  protocol    = "TCP"
  target_type = "alb"
  vpc_id      = aws_vpc.devnet.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "explorer_rpc" {
  target_group_arn = aws_lb_target_group.explorer_rpc.arn
  target_id        = aws_lb.explorer_rpc.id
  port             = 443
  depends_on = [
    aws_lb_listener.avail_explorer_443
  ]
}

resource "aws_lb_target_group" "explorer_rpc_insecure" {
  name        = "avail-alb-target-80"
  port        = 80
  protocol    = "TCP"
  target_type = "alb"
  vpc_id      = aws_vpc.devnet.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "explorer_rpc_insecure" {
  target_group_arn = aws_lb_target_group.explorer_rpc_insecure.arn
  target_id        = aws_lb.explorer_rpc.id
  port             = 80
  depends_on = [
    aws_lb_listener.avail_explorer_80
  ]
}

resource "aws_lb_listener" "alb_443_pass" {
  load_balancer_arn = aws_lb.avail_nodes.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.explorer_rpc.arn
  }
}
resource "aws_lb_listener" "alb_80_pass" {
  load_balancer_arn = aws_lb.avail_nodes.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.explorer_rpc_insecure.arn
  }
}
