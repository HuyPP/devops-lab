output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}
output "alb_role_arn" {
  value = module.eks.alb_role_arn
}
output "karpenter_role_arn" {
  value = module.eks.karpenter_role_arn
}