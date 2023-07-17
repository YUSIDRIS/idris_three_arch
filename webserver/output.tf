output "internet_lb_sg_id" {
    value = aws_security_group.internet_lb_sg.id
}

output "internet_lb_arn" {
    value = aws_lb.internet_lb.arn
}

output "target_group_internet_arn" {
    value = aws_lb_target_group.target_group_internet.arn
}

output "front_end_listener" {
    value = aws_lb_listener.front_end_listener.arn
}

output "internal_lb_sg_id" {
    value = aws_security_group.internal_lb_sg.id
}

output "target_group_internal_arn" {
    value = aws_lb_target_group.target_group_internal.arn
}

output "internal_lb_arn" {
    value = aws_lb.internal_lb.arn
}

output "back_end_listener" {
    value = aws_lb_listener.back_end_listener
}

output "internal_instance_SG" {
    value = aws_security_group.internal_instance_SG.id
}

output "internet_instance_SG" {
    value = aws_security_group.web_instance_SG.id
}

output "key_pair" {
    value = aws_key_pair.id_key.key_name
}

output "webservers_template" {
    value = aws_launch_template.webservers_template.id
}

output "public_asg" {
    value = aws_autoscaling_group.instance-asg.arn
}

output "public_asgpolicy" {
    value = aws_autoscaling_policy.public_asgpolicy.id
}

output "internalservertemplate" {
    value = aws_launch_template.internalserver.id
}
output "private_instance_asg" {
    value = aws_autoscaling_group.private_instance-asg.arn
}
output "private_asgpolicy" {
    value = aws_autoscaling_policy.private_asgpolicy.id
}
