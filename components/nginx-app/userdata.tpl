#!/bin/bash

set -euxo pipefail

yum remove -y java-1.7.0-openjdk
yum install -y java-1.8.0 git nginx

git clone https://github.com/kenych/artifacts
cd artifacts
# or just curl -O https://raw.githubusercontent.com/kenych/artifacts/master/gs-spring-boot-0.1.0.jar
java -jar ${app_name}-${app_version}.jar &

cat <<EOF > /etc/nginx/nginx.conf

events {
    worker_connections 1024;
}

http {
    server {
        listen 80;

        location / {
            proxy_pass http://localhost:8080;
        }
    }
}
EOF
service nginx start
