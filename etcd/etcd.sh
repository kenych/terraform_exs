#!/bin/bash

set -euxo pipefail

sleep 30

AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | cut -b 10)

apt-get update
apt-get -y install wget python-pip

locale-gen en_GB.UTF-8
pip install --no-cache-dir awscli

VOLUME_ID=$(aws ec2 describe-volumes --filters "Name=status,Values=available"  Name=tag:Name,Values=ebs_etcd_$AVAILABILITY_ZONE --query "Volumes[].VolumeId" --output text --region eu-west-2)

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

aws ec2 attach-volume --region eu-west-2 \
              --volume-id "${VOLUME_ID}" \
              --instance-id "${INSTANCE_ID}" \
              --device "/dev/xvdf"

while [ -z $(aws ec2 describe-volumes --filters "Name=status,Values=in-use"  Name=tag:Name,Values=ebs_etcd_$AVAILABILITY_ZONE --query "Volumes[].VolumeId" --output text --region eu-west-2) ] ; do sleep 10; echo "ebs not ready"; done

sleep 5

if [[ -z $(blkid /dev/xvdf) ]]; then
  mkfs -t ext4 /dev/xvdf  
fi

mkdir -p /opt/etcd
mount /dev/xvdf /opt/etcd


ETCD_VERSION="v3.3.8"
ETCD_URL="https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz"
ETCD_CONFIG=/etc/etcd


apt-get update
apt-get -y install wget python-pip
pip install --no-cache-dir awscli

useradd etcd

wget ${ETCD_URL} -O /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
tar -xzf /tmp/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -C /tmp
install --owner root --group root --mode 0755     /tmp/etcd-${ETCD_VERSION}-linux-amd64/etcd /usr/bin/etcd
install --owner root --group root --mode 0755     /tmp/etcd-${ETCD_VERSION}-linux-amd64/etcdctl /usr/bin/etcdctl
install -d --owner root --group root --mode 0755 ${ETCD_CONFIG}

cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd key-value store

[Service]
User=etcd
Type=notify
ExecStart=/usr/bin/etcd --config-file=/etc/etcd/etcd.conf
Restart=always
RestartSec=10s
LimitNOFILE=40000

[Install]
WantedBy=ready.target

EOF

chmod 0644 /etc/systemd/system/etcd.service


mkdir -p /opt/etcd/data
chown -R etcd:etcd /opt/etcd


cat > /etc/etcd/etcd.conf <<EOF

name: 'etcd-AZONE.k8s.ifritltd.co.uk'
data-dir: /opt/etcd/data
wal-dir: /opt/etcd/wal
snapshot-count: 10000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: https://0.0.0.0:2380
listen-client-urls: https://0.0.0.0:2379
max-snapshots: 5
max-wals: 5
initial-advertise-peer-urls: https://etcd-AZONE.k8s.ifritltd.co.uk:2380
advertise-client-urls: https://etcd-AZONE.k8s.ifritltd.co.uk:2379
discovery-fallback: 'proxy'
initial-cluster: 'etcd-a.k8s.ifritltd.co.uk=https://etcd-a.k8s.ifritltd.co.uk:2380,etcd-b.k8s.ifritltd.co.uk=https://etcd-b.k8s.ifritltd.co.uk:2380,etcd-c.k8s.ifritltd.co.uk=https://etcd-c.k8s.ifritltd.co.uk:2380'
initial-cluster-token: 'etcd-cluster'
initial-cluster-state: 'new'
strict-reconfig-check: false
enable-v2: true
enable-pprof: true
proxy: 'off'
proxy-failure-wait: 5000
proxy-refresh-interval: 30000
proxy-dial-timeout: 1000
proxy-write-timeout: 5000
proxy-read-timeout: 0
client-transport-security:
  cert-file: /etc/ssl/server.pem
  key-file: /etc/ssl/server-key.pem
  client-cert-auth: false
  trusted-ca-file: /etc/ssl/certs/ca.pem
  auto-tls: false
peer-transport-security:
  cert-file: /etc/ssl/server.pem
  key-file: /etc/ssl/server-key.pem
  peer-client-cert-auth: false
  trusted-ca-file: /etc/ssl/certs/ca.pem
  auto-tls: false
debug: false
logger: zap
log-outputs: [stderr]
force-new-cluster: false
auto-compaction-mode: periodic
auto-compaction-retention: "1"

EOF

sed -i s~AZONE~$AVAILABILITY_ZONE~g /etc/etcd/etcd.conf


aws ssm get-parameters --names "etcd-ca" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/ssl/certs/ca.pem 
aws ssm get-parameters --names "etcd-server" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/ssl/server.pem
aws ssm get-parameters --names "etcd-server-key" --query '[Parameters[0].Value]' --output text  --with-decryption --region eu-west-2 > /etc/ssl/server-key.pem

chmod 0600  /etc/ssl/server-key.pem
chmod 0644 /etc/ssl/server.pem
chown etcd:etcd /etc/ssl/server-key.pem
chown etcd:etcd /etc/ssl/server.pem

systemctl enable etcd
systemctl start etcd


