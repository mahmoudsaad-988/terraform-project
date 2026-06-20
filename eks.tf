data "aws_availability_zones" "available" {}


resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"  # IP range for the VPC
}


resource "aws_subnet" "eks_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true  # Enable auto-assign public IP
}


resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
}


resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.eks_vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
}


resource "aws_route_table_association" "eks_route_table_assoc" {
  count         = 2  # Associates the route table with each subnet
  subnet_id     = element(aws_subnet.eks_subnet.*.id, count.index)
  route_table_id = aws_route_table.eks_route_table.id
}


resource "aws_iam_role" "eks_role" {
  name = "eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["eks.amazonaws.com", "ec2.amazonaws.com"]
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


resource "aws_iam_role_policy_attachment" "eks_ec2_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks_role.arn


  vpc_config {
    subnet_ids = aws_subnet.eks_subnet[*].id
  }
}


resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_role.arn
  subnet_ids      = aws_subnet.eks_subnet[*].id


  scaling_config {
    desired_size = 2  # Initial number of nodes
    max_size     = 3  # Maximum number of nodes
    min_size     = 1  # Minimum number of nodes
  }


  instance_types = ["t3.medium"]  # Type of EC2 instances for worker nodes
}
