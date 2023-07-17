# this the security group of webservers
resource "aws_security_group" "web_instance_SG" {
  name        = "webservers_sg"
  description = "for web_server to internet Lb and my IP"
  vpc_id      =  data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "HTTP TO webserver and my ip"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    security_groups = [aws_security_group.internet_lb_sg.id]
  }
 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name =  "${var.idris_prefix}-WEBSERVER_SG"
  }
}

# key pair for my instance
resource "aws_key_pair" "id_key" {
  key_name   = "${var.idris_prefix}-key"
  public_key = file(var.public_key_location)
}

# launch template for web server
resource "aws_launch_template" "webservers_template" {
  name_prefix            = "${var.idris_prefix}"
  image_id               = data.aws_ami.amazon_image.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.id_key.key_name
  vpc_security_group_ids = [aws_security_group.web_instance_SG.id]
  user_data              = "${base64encode(file("public_data.sh"))}"
}

# autoscaling group for web server

resource "aws_autoscaling_group" "instance-asg" {
  name                      = var.idris_prefix
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.target_group_internet.arn]
  vpc_zone_identifier       = data.terraform_remote_state.network.outputs.public_subnet_id

  launch_template {
    id      = aws_launch_template.webservers_template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "public_asgpolicy" {
  name                   = "asgpolicy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.instance-asg.name

  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}