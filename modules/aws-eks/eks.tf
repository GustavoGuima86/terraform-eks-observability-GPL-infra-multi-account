module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.29.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.vpc_private_subnets
  control_plane_subnet_ids = var.vpc_intra_subnets

  self_managed_node_groups = {

    default_node_group = {
      create = false
    }

    spot-node-group = {
      name       = "spot-node-group"
      subnet_ids = var.vpc_private_subnets

      desired_size         = 2
      min_size             = 1
      max_size             = 3
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 0
          spot_allocation_strategy                 = "lowest-price" # "capacity-optimized" described here: https://aws.amazon.com/blogs/compute/introducing-the-capacity-optimized-allocation-strategy-for-amazon-ec2-spot-instances/
        }

        override = [
          { instance_type = "t2.2xlarge" },
          { instance_type = "t3.2xlarge" },
          { instance_type = "t3a.2xlarge" }
        ]
      }

      # IAM with addon policies
      iam_role_additional_policies = {
        "custom-permissions" = aws_iam_policy.ebs_policy.arn
      }

    }

  }

  enable_cluster_creator_admin_permissions = true
}

resource "aws_iam_policy" "ebs_policy" {
  name        = "AmazonEKS_EBS_Policy"
  description = "EBS policy for EKS managed node groups"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:AttachVolume",
          "ec2:CreateVolume",
          "ec2:CreateTags",
          "ec2:DeleteVolume",
          "ec2:DescribeVolumes",
          "ec2:DetachVolume"
        ],
        Resource = ["*"]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

module "ebs_csi" {

  source = "../ebs-csi-driver"

  cluster_name                     = module.eks.cluster_name
  eks_open_id_connect_provider_url = module.eks.oidc_provider
  account_owner_id                 = data.aws_caller_identity.current.account_id
  aws_region                       = data.aws_region.current.name

}

module "eks_blueprints_kubernetes_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_version   = module.eks.cluster_version

  eks_addons = {}

  enable_metrics_server               = true
  enable_cluster_autoscaler           = false
  enable_aws_load_balancer_controller = true


  aws_load_balancer_controller = {
    values = ["vpcID: ${var.vpc_id}"]
  }
}
