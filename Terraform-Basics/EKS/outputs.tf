output "cluster_endpoint" {
  value = data.aws_eks_cluster.eks.endpoint
}

output "cluster_ca" {
  value = data.aws_eks_cluster.eks.certificate_authority[0].data
}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.eks.token
}

output "cluster_name" {
  value = aws_eks_cluster.eks.name
}
