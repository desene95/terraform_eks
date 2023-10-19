locals {
    env_config = yamldecode(file("${get_terragrunt_dir()}/../config_main.yaml"))
    resources = yamldecode(file("${get_terragrunt_dir()}/../config_env_resources.yaml"))
    
}

terraform {
    source = "/Users/damianesene/terraform_eks/modules/priv_subnets"
}

inputs = {
    cidr_block = local.resources.global.network.subnets.priv_subnet_2.cidr_block
    zones      = local.resources.global.network.subnets.priv_subnet_2.zones
    vpc_name = local.resources.global.network.vpc.vpc_name
    vpc_cidr_block = local.resources.global.network.vpc.cidr_block
}

include {
  path = find_in_parent_folders()
}