#!/bin/bash
set -ex

# Wait for cloud-init to finish creating the ubuntu user
while [ ! -d /home/ubuntu ]; do
  sleep 2
done

# Update system
apt-get update -y

# Install Docker
apt-get install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Install Java
apt-get install -y openjdk-17-jdk

# Install Git
apt-get install -y git

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Create Jenkins agent directory
mkdir -p /home/ubuntu/jenkins
chown ubuntu:ubuntu /home/ubuntu/jenkins
