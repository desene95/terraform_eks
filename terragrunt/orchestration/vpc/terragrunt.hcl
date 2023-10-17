locals {
    env_config = yamldecode(file("${get_terragrunt_dir()}/../config_main.yaml"))
    resources = yamldecode(file("${get_terragrunt_dir()}/../config_env_resources.yaml"))
    
}

terraform {
    source = "/Users/damianesene/terraform_eks/modules/network"
}

inputs = {
    vpc_name = local.resources.global.network.vpc.vpc_name
    cidr_block = local.resources.global.network.vpc.cidr_block
    #location = local.resources.global.network.vpc.location
    # subnet_1 = local.resources.global.network.subnets.priv_subnet_1.cidr_block
    # subnet_2 = local.resources.global.network.subnets.priv_subnet_2.cidr_block
    # subnet_3 = local.resources.global.network.subnets.pub_subnet_1.cidr_block
    # subnet_4 = local.resources.global.network.subnets.pub_subnet_2.cidr_block
    # map_public_ip_on_launch = local.resources.global.network.subnets.pub_subnet_1.map_pub_ip
    #mtu = local.network.internal.network.mtu
}

# remote_state {
#   backend = "terragrunt"
#   config = {
#     source = "${get_terragrunt_dir()}/../terragrunt.hcl"
#   }
# }

include {
  path = find_in_parent_folders()
}