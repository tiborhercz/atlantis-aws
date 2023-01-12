resource "aws_lb" "atlantis" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = var.network_configuration.public_subnets
  security_groups    = [aws_security_group.atlantis_loadbalancer_security_group.id]
}

resource "aws_lb_target_group" "atlantis" {
  name        = var.name
  vpc_id      = var.network_configuration.vpc_id
  port        = 4141
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    path = "/healthz"
  }

  depends_on = [aws_lb.atlantis]
}

resource "aws_lb_listener" "atlantis" {
  load_balancer_arn = aws_lb.atlantis.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.atlantis.arn
  }
}

resource "aws_security_group" "atlantis_loadbalancer_security_group" {
  name   = "atlantis_loadbalancer_security_group"
  vpc_id = var.network_configuration.vpc_id
}

resource "aws_security_group_rule" "atlantis_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.atlantis_loadbalancer_security_group.id
}

resource "aws_security_group_rule" "atlantis_egress_lb" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.atlantis_loadbalancer_security_group.id
}

resource "aws_security_group" "atlantis_security_group" {
  name   = "atlantis_security_group"
  vpc_id = var.network_configuration.vpc_id
}

resource "aws_security_group_rule" "atlantis_ingress_atlantis_port" {
  type              = "ingress"
  from_port         = 4141
  to_port           = 4141
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.atlantis_security_group.id
}

resource "aws_security_group_rule" "atlantis_egress" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.atlantis_security_group.id
}
