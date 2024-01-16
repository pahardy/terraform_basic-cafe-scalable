#Creating SG to allow the HTTP traffic to the EC2 instances
resource "aws_security_group" "sg_cafe" {
  name = "cafe-allow-http"
  description = "Allow HTTP traffic to the instances hosting the cafe app"
  vpc_id = data.aws_vpc.default-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_blocks]
  }
}

#Creating SG to allow HTTP traffic to the LB
resource "aws_security_group" "sg_cafe-lb" {
  name = "cafe-allow-http-lb"
  description = "Allow HTTP traffic to the LB fronting the cafe app"
  vpc_id = data.aws_vpc.default-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.cidr_blocks]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_blocks]
  }
}

#Creating the AWS launch configuration
resource "aws_launch_configuration" "aws_launch_config_cafe" {
  name          = "cafe_launch_config"
  image_id      = var.cafe-ami
  instance_type = "t3.small"
  security_groups = [aws_security_group.sg_cafe.id]
  user_data = file("app1-install.sh")

  lifecycle {
    create_before_destroy = true
  }
}

#Creating the AutoScaling group
resource "aws_autoscaling_group" "aws_asg_cafe" {
  name = "asg_cafe"
  max_size = var.asg-max
  min_size = var.asg-min
  desired_capacity = var.asg-desired
  launch_configuration = aws_launch_configuration.aws_launch_config_cafe.name
  vpc_zone_identifier = data.aws_subnets.asg-subnets.ids
  target_group_arns = [aws_lb_target_group.cafe-lb-target-group.arn]
  health_check_type = "ELB"
  tag {
    key                 = "Name"
    value               = "scalable-cafe-app"
    propagate_at_launch = true
  }
}

#Creating the load balancer
resource "aws_lb" "cafe-app-lb" {
  name = "cafe-app-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.asg-subnets.ids
  security_groups = [aws_security_group.sg_cafe-lb.id]
}

#Creating listener for the load balancer
resource "aws_lb_listener" "cafe-lb-listener" {
  load_balancer_arn = aws_lb.cafe-app-lb.arn
  port = var.http-port
  protocol = var.lb-protocol

  default_action {
    type             = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not found"
      status_code = 404
    }
  }
}

#Create target group for the LB
resource "aws_lb_target_group" "cafe-lb-target-group" {
  name = "cafe-lb-tg"
  port = var.http-port
  protocol = var.lb-protocol
  vpc_id = data.aws_vpc.default-vpc.id

  health_check {
    path = "/"
    protocol = var.lb-protocol
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "cafe-lb-listener-rule" {
  listener_arn = aws_lb_listener.cafe-lb-listener.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.cafe-lb-target-group.arn
  }
}
