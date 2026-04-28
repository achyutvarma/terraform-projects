locals {
  name_prefix = lower(var.naming_prefix)
  alb_name    = substr("${local.name_prefix}-alb", 0, 32)
  tg_name     = substr("${local.name_prefix}-tg", 0, 32)
  asg_name    = "${local.name_prefix}-asg"
}