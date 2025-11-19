resource "aws_key_pair" "eks" {
  key_name   = "eks"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDfR/vqwOF+eA1OW7T36OrIN5xOzezKGRmxw0vLBSl84wL9c5Mpx5nooZP8EHPSxtqkD8M4LK6UZithshTQAkJuTcVZHLlOEEyZqITVUgJWMxnVl3ZneiAlid/KoR5WdgY6qJm7AqGAzbCS08WH6WZLaWKZQNEM2m140AUJXLmrvTJAWpOOqlj3pjBPpFhmzRxqvlWK8i9kLI+2PBPD28Wc3TNaN8JyeGFRgPEyGAdxhfMFA0lO/VrASZNlSNhQReTb1o+itbTqpp9DfPWIBLdZkbfcrkrQJyzkbEB3W0XBfCinkElbmrbq3HKBwQqODLRt3sTBacVCDvXTbEQVedmgtGEJ3wd58/BwyoRCBEuLXWHh+8AoxV/yIei4bXQx1JydatnmmJdyhy6TrVxEfo4s4hGob4lm+igyMTrSRI6HzmqRoBj0/Q5qWs6LRdVfVX2nBQrSwoXREPQk8ShjlBWRGWlT0zdVXkTgC+yoOVdwVvvjazO0ihugsKV+LHUe3NFgenOti0iBQzIz6Og+gbMqXO1ZuJDINJd30fWZwo9PtU2xRguWg4cFprKJ+idHIFGxTAsHyJxgAPncpk0V3bXRJACmuN5Wdhk6TEhVJ+2amMAM2vg9adZfpJCXW/mOw1reVb43yGLe2MbzdQHllgTZ8gQEPw61iTybFBM91UV7iw== ec2-user"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = data.aws_ssm_parameter.vpc_id.value
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  create_cluster_security_group = false
  cluster_security_group_id     = local.eks_control_plane_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    green = {
      min_size     = 3
      max_size     = 10
      desired_size = 3

      capacity_type = "SPOT"

      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess    = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }

      key_name = aws_key_pair.eks.key_name
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = var.common_tags
}