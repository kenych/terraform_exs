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
locale-gen en_GB.UTF-8
pip install --no-cache-dir awscli
apt-mark hold kubelet kubeadm kubectl

systemctl daemon-reload
systemctl restart kubelet

# initialize cluster with flannel cni
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all

# configure kubeconfig for kubectl
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

# install flannel
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

sleep 5
aws ssm put-parameter --name "stack-k8s-init-token" --value "$(kubeadm token create)"  --type "SecureString" --region eu-west-2 --overwrite 
aws ssm put-parameter --name "stack-k8s-init-token-hash" --value "$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')"  --type "SecureString" --region eu-west-2 --overwrite 
aws ssm put-parameter --name "stack-k8s-ip-address" --value "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)" --type "SecureString" --region eu-west-2 --overwrite 

kubectl --kubeconfig=/etc/kubernetes/admin.conf taint nodes --all node-role.kubernetes.io/master-
