
terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket         = "smartshop-tf-state-19092002" 
    key            = "dev/network/terraform.tfstate"
    region         = "ap-southeast-1"
    use_lockfile   = true
    #dynamodb_table = "smartshop-tf-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls  = { source = "hashicorp/tls", version = "~> 4.0" }
    http = { source = "hashicorp/http", version = "~> 3.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "../../modules/network"

  environment          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones   = ["ap-southeast-1a", "ap-southeast-1b"]
}
module "eks" {
  source = "../../modules/eks"

  environment        = "dev"
  cluster_name       = "smartshop-dev"
  cluster_version    = "1.30"
  private_subnet_ids = module.network.private_subnet_ids
}