# 1. Tạo EKS Control Plane
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true # Cho phép bạn gọi kubectl từ laptop
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# 2. Tạo Managed Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnet_ids # Chạy EC2 trong Private Subnet

  # Dùng t3.medium vì Kubernetes tốn khá nhiều RAM cho các agent nền
  instance_types = ["t3.micro"]
  ami_type       = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
  ]
}   

# Lấy thông tin TLS certificate của OIDC EKS
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# Tạo OIDC Provider trong IAM
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}