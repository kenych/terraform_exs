#!/bin/bash

set -euxo pipefail

# DOCKER SETUP

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
apt-get update && apt-get install -y  docker-ce=18.06.0~ce~3-0~ubuntu

# configure docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# setup systemd docker service drop-in directory
mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker

# K8S SETUP

# install required k8s tools
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat >/etc/apt/sources.list.d/kubernetes.list <<EOF
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl daemon-reload
systemctl restart kubelet

# install awscli
locale-gen en_GB.UTF-8
apt install -y python-pip
pip install --no-cache-dir awscli

# wait for master node
while [ "None" = "$(aws ssm get-parameters --names 'stack-k8s-ip-address' --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2)" ];do echo "waiting for master"; sleep 5;done

# retrieve master node invitation details
TOKEN=$(aws ssm get-parameters --names "stack-k8s-init-token" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2)
DISCOVERY_TOKEN_CA_CERT_HASH=$(aws ssm get-parameters --names "stack-k8s-init-token-hash" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2)
IP_ADDRESS=$(aws ssm get-parameters --names "stack-k8s-ip-address" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2)

# join the cluster finally
kubeadm join ${IP_ADDRESS}:6443 --token ${TOKEN} --discovery-token-ca-cert-hash sha256:${DISCOVERY_TOKEN_CA_CERT_HASH}

