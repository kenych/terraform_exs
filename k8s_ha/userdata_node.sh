#!/bin/bash

set -euxo pipefail

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

K8S_VERSION=1.12.3-00
apt-get update
apt-get install -y kubelet=${K8S_VERSION} kubeadm:amd64=${K8S_VERSION} kubectl:amd64=${K8S_VERSION} python-pip
apt-mark hold kubelet kubeadm kubectl

locale-gen en_GB.UTF-8
pip install --no-cache-dir awscli

systemctl daemon-reload
systemctl restart kubelet

#slave node

# wait for master node
while [ "None" = "$(aws ssm get-parameters --names 'k8s-init-token' --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2)" ];do echo "waiting for init master"; sleep 5;done
 
TOKEN=$(aws ssm get-parameters --names "k8s-init-token" --query '[Parameters[0].Value]' --output text --with-decryption  --region eu-west-2)
TOKEN_HASH=$(aws ssm get-parameters --names "k8s-init-token-hash" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2)

kubeadm join kubernetes.k8s.ifritltd.co.uk:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$TOKEN_HASH 

# configure kubeconfig for kubectl
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

