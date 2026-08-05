variable "vpc_cidr" {
  description = "CIDR block cho VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Tên môi trường (dev, staging, prod)"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Danh sách CIDR cho các Public Subnet"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Danh sách CIDR cho các Private Subnet"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Danh sách các AZs sẽ sử dụng"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}