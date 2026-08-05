# 1. Tạo VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "smartshop-vpc-${var.environment}"
    Environment = var.environment
  }
}

# 2. Tạo Internet Gateway (IGW)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "smartshop-igw-${var.environment}"
    Environment = var.environment
  }
}

# 3. Tạo Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                           = "smartshop-public-subnet-${count.index + 1}-${var.environment}"
    Environment                                    = var.environment
    "kubernetes.io/role/elb"                       = "1" # Cực kỳ quan trọng cho AWS ALB Controller sau này!
  }
}

# 4. Tạo Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                           = "smartshop-private-subnet-${count.index + 1}-${var.environment}"
    Environment                                    = var.environment
    "kubernetes.io/role/internal-elb"              = "1" # Quan trọng cho Internal Load Balancer của EKS
    "karpenter.sh/discovery"            = "smartshop-dev"
  }
}

# 5. Tạo Elastic IP cho NAT Gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "smartshop-nat-eip-${var.environment}"
    Environment = var.environment
  }
}

# 6. Tạo NAT Gateway ở Public Subnet đầu tiên
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name        = "smartshop-nat-${var.environment}"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

# 7. Route Table cho Public Subnets (Trỏ ra IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "smartshop-public-rt-${var.environment}"
    Environment = var.environment
  }
}

# Associte Public Route Table với các Public Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 8. Route Table cho Private Subnets (Trỏ ra NAT Gateway)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "smartshop-private-rt-${var.environment}"
    Environment = var.environment
  }
}

# Associate Private Route Table với các Private Subnets
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}