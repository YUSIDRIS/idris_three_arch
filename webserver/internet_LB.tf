# this the security group of internet load balancer
resource "aws_security_group" "internet_lb_sg" {
  name        = "internet_lb_sg"
  description = "for internet lb to everyone"
  vpc_id      =  data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "HTTP TO EVERYONE"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name =  "${var.idris_prefix}-INTERNET_LB_SG"
  }
}
# create internet load balancer
resource "aws_lb" "internet_lb" {
  name               = "internetLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internet_lb_sg.id]
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_id

  tags = {
    Name = "${var.idris_prefix}-INTERNET_LB"
  }
}
# the target group of the internet load balancer
resource "aws_lb_target_group" "target_group_internet" {
  name        = "targetgroupinternet"
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
resource "aws_lb_listener" "front_end_listener" {
  load_balancer_arn = aws_lb.internet_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group_internet.arn


  }
}

