# Tải Policy chuẩn từ AWS
data "http" "alb_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.8.1/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_controller" {
  name   = "${var.cluster_name}-alb-policy"
  policy = data.http.alb_policy.response_body
}

# Tạo Role với kỹ thuật IRSA (Chỉ cho phép đúng ServiceAccount của ALB được dùng)
resource "aws_iam_role" "alb_controller" {
  name = "${var.cluster_name}-alb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        "StringEquals" = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}

# Xuất giá trị ARN của Role để lát nữa cài Helm
output "alb_role_arn" {
  value = aws_iam_role.alb_controller.arn
}
# --- Karpenter Controller IAM ---
resource "aws_iam_role" "karpenter_controller" {
  name = "${var.cluster_name}-karpenter-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"  
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        "StringEquals" = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:karpenter"
        }
      }
    }]
  })
}

# Policy cấp quyền quản lý EC2
resource "aws_iam_role_policy" "karpenter_policy" {
  name   = "${var.cluster_name}-karpenter-policy"
  role   = aws_iam_role.karpenter_controller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "iam:PassRole",
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate",
          "ec2:Describe*",
          "ssm:GetParameter",
          "eks:DescribeCluster",
          "iam:CreateInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:TagInstanceProfile"
        ]
        Resource = "*"
      }
    ]
  })
}
output "karpenter_role_arn" {
  value = aws_iam_role.karpenter_controller.arn
}