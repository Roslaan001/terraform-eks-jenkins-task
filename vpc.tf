data "aws_availability_zones" "available-azs" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name               = "my-vpc"
  cidr               = var.vpc_cidr
  azs                = data.aws_availability_zones.available-azs.names
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_support = true
  tags = {
    "Terraform"                                 = "true"
    "Environment"                               = var.env_prefix
    "kubernetes.io/cluster/my-eks-cluster-task" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
    "Name"                                      = "eks-vpc"
  }



  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster-task" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster-task" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
  enable_dns_hostnames = true
  single_nat_gateway   = true
}