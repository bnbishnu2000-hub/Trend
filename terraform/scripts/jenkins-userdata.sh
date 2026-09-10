#!/bin/bash
set -euxo pipefail

# Bootstrap for the Jenkins controller on Ubuntu 24.04 LTS.
# Progress is visible at /var/log/cloud-init-output.log on the instance.

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y curl unzip git jq gnupg ca-certificates lsb-release \
  fontconfig openjdk-17-jre-headless

# --- Swap ------------------------------------------------------------------
# t3.micro has 1 GiB of RAM. Jenkins alone holds roughly 320 MB, and a
# concurrent `docker build` will otherwise trigger the OOM killer, which
# terminates the Jenkins JVM mid-build.
if [ ! -f /swapfile ]; then
  fallocate -l 1G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# --- Docker Engine ---------------------------------------------------------
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
systemctl enable --now docker

# --- Jenkins ---------------------------------------------------------------
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list

apt-get update
apt-get install -y jenkins

# The pipeline shells out to `docker build`, so the jenkins user needs the socket.
usermod -aG docker jenkins

systemctl enable --now jenkins

# --- kubectl ---------------------------------------------------------------
K8S_MINOR="1.34"
curl -fsSLo /usr/local/bin/kubectl \
  "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable-${K8S_MINOR}.txt)/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

# --- Helm ------------------------------------------------------------------
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# --- AWS CLI v2 ------------------------------------------------------------
# Ubuntu's `awscli` package is v1 and does not support EKS token generation
# correctly. v2 must be installed from the official archive.
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

# Jenkins writes its kubeconfig here.
install -d -o jenkins -g jenkins /var/lib/jenkins/.kube

# Restart so the docker group membership applies to the running Jenkins process.
systemctl restart jenkins

echo "Bootstrap complete."
