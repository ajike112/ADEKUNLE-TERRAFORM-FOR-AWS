#!/bin/bash

# Delay to avoid cloud-init apt lock conflicts
sleep 60

# Wait for ubuntu home directory
while [ ! -d /home/ubuntu ]; do
  sleep 2
done

# Update package index
until sudo apt-get update -y; do
  sleep 2
done

# Install base packages
until sudo apt-get install -y ca-certificates curl gnupg unzip wget git maven lsb-release openjdk-17-jre-headless; do
  sleep 2
done

# Install Node.js 18
until curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -; do
  sleep 2
done

until sudo apt-get install -y nodejs; do
  sleep 2
done

# Docker repository setup
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
until sudo apt-get update -y; do
  sleep 2
done

until sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; do
  sleep 2
done

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

# Install AWS CLI v2
curl -L https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install

# Jenkins workspace
sudo mkdir -p /home/ubuntu/jenkins
sudo chown ubuntu:ubuntu /home/ubuntu/jenkins

# Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh || true

# DependencyCheck
cd /opt
wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip
unzip dependency-check-8.4.0-release.zip -d dependency-check
ln -s /opt/dependency-check/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check.sh

# DependencyCheck config directory
mkdir -p /home/ubuntu/.dependency-check
echo "nvd.api.key=8DEE2BA3-8BB4-4F79-809C-03F6564FBC04" > /home/ubuntu/.dependency-check/dependency-check.properties
chown -R ubuntu:ubuntu /home/ubuntu/.dependency-check


# SonarScanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip || true
unzip sonar-scanner-cli-5.0.1.3006-linux.zip || true
sudo mv sonar-scanner-5.0.1.3006-linux sonar-scanner || true
echo "export PATH=/opt/sonar-scanner/bin:$PATH" | sudo tee -a /etc/profile
