
# Notes

## Test ports

```
echo hi | nc -l 1194
```

## Install tools
```
curl -O http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

yum install -y openvpn
yum install -y easy-rsa
```

## PKI

```
mkdir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
PATH=$PATH:/usr/share/easy-rsa/3.0.3/
echo $PATH
easyrsa init-pki
ls /etc/openvpn/easy-rsa/pki
easyrsa build-ca

openssl x509 -text -noout -in /etc/openvpn/easy-rsa/pki/ca.crt | grep CA

easyrsa gen-dh

easyrsa gen-req server nopass

easyrsa sign-req server server

easyrsa gen-req client nopass

easyrsa sign-req client client

# add as many as you want:
# easyrsa gen-req client1 nopass
# easyrsa sign-req client client1

# easyrsa gen-req client2 nopass
# easyrsa sign-req client client2
# ..
# .....
# easyrsa gen-req clientN nopass
# easyrsa sign-req client clientN

# or with pass (then same will be used when connecting on client side):
# easyrsa gen-req clientN
# easyrsa sign-req client clientN

cd /etc/openvpn/
openvpn --genkey --secret pfs.key
```

## Server config

```
vi server.conf

port 1194
proto tcp
dev tun
ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key
dh /etc/openvpn/easy-rsa/pki/dh.pem
topology subnet
cipher AES-256-CBC
auth SHA512
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.8.4"
ifconfig-pool-persist ipp.txt
keepalive 10 120
comp-lzo
persist-key
persist-tun
status openvpn-status.log
log-append openvpn.log
verb 3
tls-server
tls-auth /etc/openvpn/pfs.key


systemctl start openvpn@server

journalctl -eu openvpn@server
```
## PKI for client

```
mkdir -p server1/keys
cp pfs.key server1/keys/
cp easy-rsa/pki/dh.pem server1/keys/
cp easy-rsa/pki/ca.crt server1/keys/
cp easy-rsa/pki/private/ca.key server1/keys/
cp easy-rsa/pki/private/client.key server1/keys/
cp easy-rsa/pki/issued/client.crt server1/keys/
tar cvzf /tmp/keys.tgz server1

```

## NAT settings

```
sysctl -w net.ipv4.conf.all.forwarding=0
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

```

## Configure client

```
scp 10.0.1.10:/tmp/keys.tgz /tmp/keys.tgz

sudo -i
<!-- install openvpn,   -->
cd /etc/openvpn/

  
tar xvfz /tmp/keys.tgz

[root@ip-172-31-2-106 openvpn]# ll
total 8
drwxr-x---. 2 root openvpn    6 Apr 26  2018 client
-rw-r--r--. 1 root root    6733 Feb  1 19:51 keys.tgz
drwxr-x---. 2 root openvpn    6 Apr 26  2018 server
drwxr-xr-x. 3 root root      18 Feb  1 19:21 server1
[root@ip-172-31-2-106 openvpn]#

```

## Vpn client config
```

vi client.conf
client
proto tcp
dev tun
remote 10.0.1.10 1194
ca server1/keys/ca.crt
cert server1/keys/client.crt
key server1/keys//client.key
tls-version-min 1.2
tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256
cipher AES-256-CBC
auth SHA512
resolv-retry none
nobind
route-nopull
persist-key
persist-tun
ns-cert-type server
comp-lzo
verb 3
tls-client
tls-auth server1/keys/pfs.key


systemctl start openvpn@client

journalctl -eu openvpn@client
```

### Client Routing

```
ip r add 10.0.1.20 dev tun0
```

### on MacOS:

All same apart public IP of VPN:

```
grep remote     /Users/$USER/Library/Application\ Support/Tunnelblick/Configurations/config.tblk/Contents/Resources/config.ovpn
remote 18.130.154.13 1194
```

and routing:

```
sudo route -n add -net 10.0.1.0/24 10.8.0.2
```

Test
```
netstat -rn | grep '10.0.1/24'
10.0.1/24          10.8.0.2           UGSc            0        0   utun3
```

