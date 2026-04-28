variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "my_ip" {
  type = string
}
variable "key_name" {
  type = string
}

variable "naming_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
