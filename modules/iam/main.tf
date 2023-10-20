#create an IAM role
resource "aws_iam_role" "eks_role"{
    name = var.eks_role_name

    assume_role_policy= jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "eks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]

    }

    )
}

resource "aws_iam_role" "nodes"{
    name = var.eks_node_role_name

    assume_role_policy = jsonencode({
        Statement = [{
            Action      =   "sts:AssumeRole"
            Effect      =    "Allow"
            Principal   =    {
                Service = "ec2.amazonaws.com"
            }
        }]
        Version = "2012-10-17"
    })

}

#Attach policy to role
resource "aws_iam_role_policy_attachment" "eks_role_pol_att"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "nodes"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-CNI"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-container-registry"{
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = aws_iam_role.nodes.name
}

output "eks_role_arn"{
    value = aws_iam_role.eks_role.arn
}

output "node_role_arn"{
    value = aws_iam_role.nodes.arn
}