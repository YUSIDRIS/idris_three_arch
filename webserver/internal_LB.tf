# this the security group of internal load balancer
resource "aws_security_group" "internal_lb_sg" {
  name        = "internal_lb_sg"
  description = "for internal lb to everyone"
  vpc_id      =  data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "HTTP TO WEBSERVER"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.web_instance_SG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name =  "${var.idris_prefix}-INTERNAL_LB_SG"
  }
}
# create internal load balancer
resource "aws_lb" "internal_lb" {
  name               = "internalLB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_lb_sg.id]
  subnets            = data.terraform_remote_state.network.outputs.private_subnet_id

  tags = {
    Name = "${var.idris_prefix}-INTERNAL_LB"
  }
}
# the target group of the internal load balancer
resource "aws_lb_target_group" "target_group_internal" {
  name        = "targetgroupinternal"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  
  health_check {
    path                        = "/"
    enabled                     = true
    healthy_threshold           = 2
    unhealthy_threshold         = 2
    matcher                     = 200
    port                        = 80
    timeout                     = 5
    interval                    = 30
  }
}

# listener for the load balancer
resource "aws_lb_listener" "back_end_listener" {
  load_balancer_arn = aws_lb.internal_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group_internal.arn


  }
}
