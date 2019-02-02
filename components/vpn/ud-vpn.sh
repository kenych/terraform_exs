#!/bin/bash

yum update -y


curl -O http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

yum install -y nmap-ncat.x86_64 easy-rsa openvpn tcpdump
