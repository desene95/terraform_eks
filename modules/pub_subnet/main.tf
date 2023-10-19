data "aws_iam_policy_document" "current_config" {
  # No specific configuration is needed for this data source
}

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

resource "aws_subnet" "public"{
    vpc_id = data.terraform_remote_state.aws_vpc.outputs.vpc_id
    cidr_block = var.cidr_block
    availability_zone = var.zones
    map_public_ip_on_launch = var.map_pub_ip
    tags = {
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/demo" = "owned"

    }

}

output "subnet_id" {
    value = aws_subnet.public.id
}