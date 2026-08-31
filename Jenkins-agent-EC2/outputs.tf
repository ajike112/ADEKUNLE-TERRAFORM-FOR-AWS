output "jenkins_agent_public_ip" {
  value = aws_instance.jenkins_agent.public_ip
}

output "jenkins_agent_private_ip" {
  value = aws_instance.jenkins_agent.private_ip
}
