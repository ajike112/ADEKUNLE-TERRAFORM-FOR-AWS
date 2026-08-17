
output "private_dns" {
  description = "private dns id"
  value       = aws_instance.EC2_instance.private_dns
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks.name
}
