output "vpc_id" {
  value = module.networking.vpc_id
}

output "instance_ids" {
  value = module.compute.instance_ids
}

output "alb_dns" {
  value = module.compute.alb_dns
}
