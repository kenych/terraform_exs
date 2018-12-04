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

aws ssm delete-parameter --name "k8s-init-token"  --region eu-west-2 2>/dev/null || true

aws ssm get-parameters --names "etcd-ca" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/etcd/ca.crt
aws ssm get-parameters --names "etcd-server" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/apiserver-etcd-client.crt
aws ssm get-parameters --names "etcd-server-key" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/kubernetes/pki/apiserver-etcd-client.key


# for initial master
cat > kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1alpha3
kind: ClusterConfiguration
kubernetesVersion: stable
apiServerCertSANs:
- "kubernetes.k8s.ifritltd.co.uk"
controlPlaneEndpoint: "kubernetes.k8s.ifritltd.co.uk"
etcd:
    external:
        endpoints:
        - https://etcd-a.k8s.ifritltd.co.uk:2379
        - https://etcd-b.k8s.ifritltd.co.uk:2379
        - https://etcd-c.k8s.ifritltd.co.uk:2379
        caFile: /etc/kubernetes/pki/etcd/ca.crt
        certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
        keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
networking:
    podSubnet: "10.244.0.0/16"
EOF

kubeadm init --config kubeadm-config.yaml

# configure kubeconfig for kubectl
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

# install flannel
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml


sleep 5
# initial master
aws ssm put-parameter --name "k8s-ca" --value "$(cat /etc/kubernetes/pki/ca.crt)"  --type "SecureString" --region eu-west-2 --overwrite 
aws ssm put-parameter --name "k8s-ca-key" --value "$(cat /etc/kubernetes/pki/ca.key)"  --type "SecureString" --region eu-west-2 --overwrite 
aws ssm put-parameter --name "k8s-sa" --value "$(cat /etc/kubernetes/pki/sa.pub)"  --type "SecureString" --region eu-west-2 --overwrite 
aws ssm put-parameter --name "k8s-sa-key" --value "$(cat /etc/kubernetes/pki/sa.key)"  --type "SecureString" --region eu-west-2 --overwrite 
aws ssm put-parameter --name "k8s-front-proxy-ca" --value "$(cat /etc/kubernetes/pki/front-proxy-ca.crt)"  --type "SecureString" --region eu-west-2 --overwrite 
aws ssm put-parameter --name "k8s-front-proxy-ca-key" --value "$(cat /etc/kubernetes/pki/front-proxy-ca.key)"  --type "SecureString" --region eu-west-2 --overwrite 

sleep 5
aws ssm put-parameter --name "k8s-init-token" --value "$(kubeadm token create)"  --type "SecureString" --region eu-west-2 --overwrite 
