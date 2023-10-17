resource "aws_subnet" "public"{
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_block
    availability_zone = var.zones
    map_public_ip_on_launch = var.map_pub_ip
    tags = {
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/demo" = "owned"

    }

}