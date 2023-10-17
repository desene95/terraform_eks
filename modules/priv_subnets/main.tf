data "aws_iam_policy_document" "current_config" {
  # No specific configuration is needed for this data source
}
# module "vpc" {
#       source = "/Users/damianesene/terraform_eks/modules/network"
#       vpc_name = var.vpc_name
#       cidr_block = var.vpc_cidr_block
    
# }

 data "terraform_remote_state" "aws_vpc"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/vpc/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

output "vpc_id"{
    value = data.terraform_remote_state.aws_vpc.outputs
}


resource "aws_subnet" "private"{
        vpc_id = data.terraform_remote_state.aws_vpc.outputs.vpc_id
        cidr_block = var.cidr_block
        availability_zone = var.zones
        tags = {
            "kubernetes.io/role/internal-elb" = "1"
            "kubernetes.io/cluster/demo" = "owned"
        
        }

}