# this the security group of webservers
resource "aws_security_group" "internal_instance_SG" {
  name        = "internalserver_sg"
  description = "for internal_server to internet Lb and my IP"
  vpc_id      =  data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "HTTP TO  back end server"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.internal_lb_sg.id]
  }
 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name =  "${var.idris_prefix}-BACKEND_SG"
  }
}

# launch template for BACK END server
resource "aws_launch_template" "internalserver" {
  name_prefix            = "${var.idris_prefix}"
  image_id               = data.aws_ami.amazon_image.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.id_key.key_name
  vpc_security_group_ids = [aws_security_group.internal_instance_SG.id]
  user_data              = "${base64encode(file("private_data.sh"))}"
}

# autoscaling group for back endserver

resource "aws_autoscaling_group" "private_instance-asg" {
  name                      = "${var.idris_prefix}-PRIVATE"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.target_group_internal.arn]
  vpc_zone_identifier       = data.terraform_remote_state.network.outputs.private_subnet_id

  launch_template {
    id      = aws_launch_template.internalserver.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "private_asgpolicy" {
  name                   = "asgpolicy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.private_instance-asg.name

  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}