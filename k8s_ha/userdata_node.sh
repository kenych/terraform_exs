#!/bin/bash

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

# install credstash
sudo locale-gen en_GB.UTF-8
apt install -y python-pip
pip install credstash


# wait for master node
while [ ! $(credstash -r eu-west-1 get ip-address role=k8s-cluster 2> /dev/null) ];do echo waiting for master; sleep 5;done

# retrieve master node invitation details
TOKEN=$(credstash -r eu-west-1 get token  role=k8s-cluster)
DISCOVERY_TOKEN_CA_CERT_HASH=$(credstash -r eu-west-1 get discovery-token-ca-cert-hash role=k8s-cluster)
IP_ADDRESS=$(credstash -r eu-west-1 get ip-address role=k8s-cluster)

# join the cluster finally
kubeadm join ${IP_ADDRESS}:6443 --token ${TOKEN} --discovery-token-ca-cert-hash sha256:${DISCOVERY_TOKEN_CA_CERT_HASH}

