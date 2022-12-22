resource "aws_lb" "atlantis" {
  name = var.name

  load_balancer_type = "application"

  subnets         = var.private_subnets
  security_groups = [aws_security_group.atlantis_security_group.id]
}

resource "aws_lb_target_group" "atlantis" {
  name = var.name

  vpc_id   = var.vpc_id
  port     = 80
  protocol = "HTTP"

  target_type = "ip"

  health_check {
    path = "/healthz"
  }

  depends_on = [aws_lb.atlantis]

  lifecycle {
    create_before_destroy = true
  }
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


resource "aws_security_group" "atlantis_security_group" {
  name   = "atlantis_security_group"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "atlantis_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
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
