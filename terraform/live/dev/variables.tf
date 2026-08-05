variable "aws_region" {
  description = "AWS Region để deploy tài nguyên"
  type        = string
  default     = "ap-southeast-1" # Đảm bảo region trùng với aws configure của bạn
}