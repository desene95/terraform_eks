data "terraform_remote_state" "priv_sub_1"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/priv_subnet_1/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

data "terraform_remote_state" "priv_sub_2"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/priv_subnet_2/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

data "terraform_remote_state" "pub_sub_1"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/pub_subnet_1/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

data "terraform_remote_state" "pub_sub_2"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/pub_subnet_2/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

data "terraform_remote_state" "iam"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/iam/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}


#Create eks cluster
resource "aws_eks_cluster" "eks_cluster"{
    name        = var.eks_name
    role_arn    = data.terraform_remote_state.iam.outputs.eks_role_arn

    vpc_config {
        subnet_ids = [
            data.terraform_remote_state.priv_sub_1.outputs.priv_subnet_id,
            data.terraform_remote_state.priv_sub_2.outputs.priv_subnet_id,
            data.terraform_remote_state.pub_sub_1.outputs.subnet_id,
            data.terraform_remote_state.pub_sub_1.outputs.subnet_id
        ]
    }
}

#Create Node Group
resource "aws_eks_node_group" "private_nodes"{
    cluster_name = aws_eks_cluster.eks_cluster.name
    node_group_name = var.node_group_name
    node_role_arn  = data.terraform_remote_state.iam.outputs.node_role_arn
    subnet_ids = [
            data.terraform_remote_state.priv_sub_1.outputs.priv_subnet_id,
            data.terraform_remote_state.priv_sub_2.outputs.priv_subnet_id

    ]
    capacity_type = "ON_DEMAND"
    instance_types = ["t2.small"]
    scaling_config   {
        desired_size = 1
        max_size    = 1
        min_size    =1
    }
}