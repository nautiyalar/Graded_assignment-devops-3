provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "nginx_lc" {
  name_prefix          = "nginx-lc-"
  image_id             = "ami-04cb4ca688797756f" # Specify your desired AMI ID
  instance_type        = var.instance_type
  key_name             = var.key_name
  security_groups = [
    "${aws_security_group.lab-alb-sg.id}",
  ]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              service nginx start
              chkconfig nginx on
              EOF
}

resource "aws_lb_target_group" "lab-target-group" {

  name        = "lab-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

}


resource "aws_lb" "lab-alb" {
  name     = "lab-alb"
  internal = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  tags = {
    Name = "lab-alb"
  }

  subnets = [
    "${var.subnet1}",
    "${var.subnet2}",
  ]

  security_groups = [
    "${aws_security_group.lab-alb-sg.id}",
  ]


}

resource "aws_lb_listener" "lab-alb-listner" {

  protocol          = "HTTP"
  port              = 80
  load_balancer_arn = aws_lb.lab-alb.arn

  default_action {
    target_group_arn = aws_lb_target_group.lab-target-group.arn
    type             = "forward"
  }
}

resource "aws_security_group" "lab-alb-sg" {
  name   = "lab-alb-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "inbound_http" {

  type              = "ingress"

  from_port         = 80
  to_port           = 80
  protocol          = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lab-alb-sg.id
}

resource "aws_security_group_rule" "outbound_all" {

  type              = "egress"

  from_port         = 0
  to_port           = 0
  protocol          = "-1"

  security_group_id = aws_security_group.lab-alb-sg.id
  cidr_blocks       = ["0.0.0.0/0"]

}

output "load_balancer_dns" {
   value = aws_lb.lab-alb.dns_name
 }