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

data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
 #create OpenID connect provider
resource "aws_iam_openid_connect_provider" "eks"{
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
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
    instance_types = ["t3.small"]
    scaling_config   {
        desired_size = 1
        max_size    = 3
        min_size    =0
    }

    update_config {
      max_unavailable = 1
    }

    labels = {
        role = "general"
    }
}


#test provider by creating a role
data "aws_iam_policy_document" "test_oidc"{
    statement {
        actions =   ["sts:AssumeRoleWithWebIdentity"]
        effect  = "Allow"

        condition {
            test = "StringEquals"
            variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://","")}:sub"
            values = ["system:serviceaccount:default:aws-test"]
        }

        principals {
            identifiers = [aws_iam_openid_connect_provider.eks.arn]
            type    = "Federated"
        }
    }
}

resource "aws_iam_role" "test_oidc"{
    assume_role_policy = data.aws_iam_policy_document.test_oidc.json
    name = "test_oidc"
}

resource "aws_iam_policy" "test_policy"{
    name = "test_policy"

    policy = jsonencode({
        Statement = [{
            Action = [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ]
            Effect = "Allow"
            Resource = "arn:aws:s3:::*"

        }]
        Version = "2012-10-17"
    })
}

resource "aws_iam_role_policy_attachment" "test_attach"{
    role = aws_iam_role.test_oidc.name
    policy_arn = aws_iam_policy.test_policy.arn
}

output "test_policy_arn"{
    value = aws_iam_role.test_oidc.arn
}