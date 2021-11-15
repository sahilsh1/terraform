resource "aws_lb" "eternals" {
  name                             = "eternals"
  subnets                          = module.vpc.public_subnets
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "eternals" {
  load_balancer_arn = aws_lb.eternals.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.eternals-blue.id
    type             = "forward"
  }
  lifecycle {
    ignore_changes = [
      default_action,
    ]
  }
}

resource "aws_lb_target_group" "eternals-blue" {
  name                 = "eternals-http-blue"
  port                 = "3000"
  protocol             = "TCP"
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = "30"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "TCP"
    interval            = 30
  }
}
resource "aws_lb_target_group" "eternals-green" {
  name                 = "eternals-http-green"
  port                 = "3000"
  protocol             = "TCP"
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = "30"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "TCP"
    interval            = 30
  }
}