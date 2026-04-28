output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "backend_config_dev_example" {
  value = "terraform init -backend-config=\"bucket=${aws_s3_bucket.terraform_state.bucket}\""
}

output "backend_config_prod_example" {
  value = "terraform init -backend-config=\"bucket=${aws_s3_bucket.terraform_state.bucket}\""
}
