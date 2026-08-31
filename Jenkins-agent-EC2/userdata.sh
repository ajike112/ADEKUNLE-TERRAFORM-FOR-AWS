#!/bin/bash
set -ex

# Wait for cloud-init to finish creating the ubuntu user
while [ ! -d /home/ubuntu ]; do
  sleep 2
done

# Update system
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

# Install Java
sudo apt-get install -y openjdk-17-jdk

# Install Git
sudo apt-get install -y git

# Install unzip (required for AWS CLI)
sudo apt-get install -y unzip

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Create Jenkins agent directory
sudo mkdir -p /home/ubuntu/jenkins
sudo chown ubuntu:ubuntu /home/ubuntu/jenkins

# Install Maven
sudo apt-get install -y maven

