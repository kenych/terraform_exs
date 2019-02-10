#!/bin/bash

yum install -y nmap-ncat.x86_64

while true; do { echo -e 'HTTP/1.1 200 OK\r\n';      echo 'smallest http server'; } | nc -l -p  80; done &
