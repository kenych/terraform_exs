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

apt-get update
apt-get install -y kubelet kubeadm kubectl python-pip
apt-mark hold kubelet kubeadm kubectl

locale-gen en_GB.UTF-8
pip install --no-cache-dir awscli

systemctl daemon-reload
systemctl restart kubelet

mkdir -p /etc/kubernetes/pki/etcd

aws ssm get-parameters --names "etcd-ca" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/etcd/ca.crt
aws ssm get-parameters --names "etcd-server" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/apiserver-etcd-client.crt
aws ssm get-parameters --names "etcd-server-key" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/apiserver-etcd-client.key

#secondary master

# wait for master node
while [ "None" = "$(aws ssm get-parameters --names 'k8s-init-token' --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2)" ];do echo "waiting for init master"; sleep 5;done
 
aws ssm get-parameters --names "k8s-ca" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/ca.crt
aws ssm get-parameters --names "k8s-ca-key" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/ca.key
aws ssm get-parameters --names "k8s-sa" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/sa.pub
aws ssm get-parameters --names "k8s-sa-key" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/sa.key
aws ssm get-parameters --names "k8s-front-proxy-ca" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/front-proxy-ca.crt
aws ssm get-parameters --names "k8s-front-proxy-ca-key" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/front-proxy-ca.key

TOKEN=$(aws ssm get-parameters --names "k8s-init-token" --query '[Parameters[0].Value]' --output text --with-decryption  --region eu-west-2)
TOKEN_HASH=$(aws ssm get-parameters --names "k8s-init-token-hash" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2)

kubeadm join kubernetes.k8s.ifritltd.co.uk:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$TOKEN_HASH --experimental-control-plane

# configure kubeconfig for kubectl
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

