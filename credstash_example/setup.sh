#!/bin/bash

apt-get update
locale-gen en_GB.UTF-8
apt install -y python-pip
pip install credstash
