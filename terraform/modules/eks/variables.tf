variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.30" # Phiên bản Kubernetes
}

variable "private_subnet_ids" {
  description = "IDs của Private Subnets để đặt Worker Nodes"
  type        = list(string)
}