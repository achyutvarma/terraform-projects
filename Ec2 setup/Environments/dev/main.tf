
module "networking" {
  source = "../../modules/networking"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  naming_prefix = local.naming_prefix
  common_tags   = local.common_tags

  
}

module "compute" {
  source = "../../modules/compute"

  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  vpc_id    = module.networking.vpc_id
 

  my_ip = var.my_ip
  key_name = var.key_name
  naming_prefix = local.naming_prefix
  common_tags   = local.common_tags
}
