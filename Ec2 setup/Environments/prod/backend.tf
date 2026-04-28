terraform {
  backend "s3" {
    key          = "ec2-setup/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
