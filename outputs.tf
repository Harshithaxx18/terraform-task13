output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "blue_target_group_arn" {
  description = "ARN of the Blue target group."
  value       = aws_lb_target_group.env["blue"].arn
}

output "green_target_group_arn" {
  description = "ARN of the Green target group."
  value       = aws_lb_target_group.env["green"].arn
}

output "blue_asg_name" {
  description = "Name of the Blue Auto Scaling group."
  value       = aws_autoscaling_group.env["blue"].name
}

output "green_asg_name" {
  description = "Name of the Green Auto Scaling group."
  value       = aws_autoscaling_group.env["green"].name
}