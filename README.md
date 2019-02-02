# Init

Either export key/secret:

```
export AWS_SECRET_ACCESS_KEY=
export AWS_ACCESS_KEY_ID=
```
or use aws-profile with multiple profiles, first make sur AWS creds set:

```
cat ~/.aws/credentials
[default]
aws_access_key_id = ******
aws_secret_access_key = ******
region = eu-west-2
```

then use:

```
 export AWS_PROFILE=default
 aws-profile terraform ...
```

## Components

### k8s_ha

Automation of 9 node(node per 3 AZ for master/slave/etcd) k8s cluster setup with external etcd with kubeadm

### kops-terraform

Simple k8s single node setup with kops

### openVPN

`components/vpn`

Example of setting up openVPN on RHEL
