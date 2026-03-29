
output "private_dns" {
    description = "private dns id"
    value = aws_instance.EC2_instance.private_dns
}