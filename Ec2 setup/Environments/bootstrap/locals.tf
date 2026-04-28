locals {
  state_bucket_name = "${var.project}-${var.environment}-${var.aws_account_id}-tfstate"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "terraform-state"
  }
}
