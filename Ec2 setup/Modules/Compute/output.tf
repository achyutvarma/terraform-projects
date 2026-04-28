output "instance_ids" {
  value = data.aws_instances.asg_instances.ids
}

output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "private_ips" {
  value = data.aws_instances.asg_instances.private_ips
}