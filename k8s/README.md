# Automated creation of simple k8s cluster from the scratch

##  Requirements:
- existing AWS account with a user with enough permissions to create all resources
- terraform
- aws cli
##  Testing is done using
- MacOS
- for simplicity just a user with AdministratorAccess permissons.
 - tf v0.11.11
 - aws-cli/1.19.12 Python/3.6.4 Darwin/18.2.0 botocore/1.20.12

##  Setup steps for to terraform
1. to run tf we will need aws profile with credentials of the user:
```
cat ~/.aws/credentials
[kayantest]
aws_access_key_id = ******
aws_secret_access_key = ********
mfa_serial = arn:aws:iam::******:user/kayantest
region = eu-west-2
```
2. Once profile created we can expose it so tf can auth to aws:
```
export AWS_PROFILE=kayantest
```
Alternatively you can simply export key/secret, but it is not the best practice:
```
export AWS_SECRET_ACCESS_KEY=***
export AWS_ACCESS_KEY_ID=***
```
Now we can run tf to create all that is needed for simple k8s cluster. 

3. Becasue tf needs it's state file in s3 bucket, let's create that first:
```
aws s3api create-bucket --bucket kayan-terra-state2  --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2
```
4. Finally run:
```
terraform init
terraform apply
```
5. Once tf finished it will output the private key so you can use it to ssh onto the master, it's ip will also be shown (don't forget to chmod 400 the private key):

```

....Outputs:

master_node_public_ip = 18.134.156.100
private_key = -----BEGIN RSA PRIVATE KEY-----
MIIJKQIBAAKCAgEAqfYz76y6CjRAE90nKCr0v67xdGY5TntCAVtKmWWQvwOlXNdj
...

chmod 400 terra                      
(env_p3) ➜  k8s git:(master) ✗ ssh ubuntu@18.134.156.100 -i terra 
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-1128-aws x86_64)
```

Check if k8s is ready:
```
ubuntu@ip-172-31-35-236:~$ sudo -i
tail -f /var/log/cloud-init-output.log
kubeadm set on hold.
kubectl set on hold.
+ systemctl daemon-reload
+ systemctl restart kubelet
+ kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all
[init] Using Kubernetes version: v1.23.3
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
..
```
This would mean cloud init still working...
When you finally get:
```
Cloud-init v. 21.1-19-gbad84ad4-0ubuntu1~16.04.2 finished at xxx. Datasource DataSourceEc2Local.  Up 136.46 seconds
```
then you can check the cluster:
```
root@ip-172-31-35-236:~# kubectl get nodes
NAME               STATUS   ROLES                  AGE   VERSION
ip-172-31-35-236   Ready    control-plane,master   24m   v1.23.3
root@ip-172-31-35-236:~# 
```

##  Running single master node vs master with slaves
search for comment `uncomment for enable slave nodes` and uncomment if you want to spin up both baster and slaves otherwise this will be similar to minikube and pods will be scheduled to master.

##  The more advanced setup
The proper HA setup is created now and explained at https://ifritltd.com/2019/06/16/automating-highly-available-kubernetes-cluster-and-external-etcd-setup-with-terraform-and-kubeadm-on-aws/:
 - HA etcd https://github.com/kenych/terraform_exs/tree/master/etcd
 - HA k8s https://github.com/kenych/terraform_exs/tree/master/k8s_ha

...anyways if you care, most folks would be quite happy just using EKS and not bothering about the rest ;)

