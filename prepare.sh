#!/usr/bin/env bash

aws ec2 describe-regions | grep eu
#            "Endpoint": "ec2.eu-west-3.amazonaws.com",
#            "RegionName": "eu-west-3"
#            "Endpoint": "ec2.eu-west-2.amazonaws.com",
#            "RegionName": "eu-west-2"
#            "Endpoint": "ec2.eu-west-1.amazonaws.com",
#            "RegionName": "eu-west-1"
#            "Endpoint": "ec2.eu-central-1.amazonaws.com",
#            "RegionName": "eu-central-1"

aws ec2 describe-availability-zones --region eu-west-2 | jq -r  '.AvailabilityZones[].ZoneName'
#eu-west-2a
#eu-west-2b
#eu-west-2c

aws s3api create-bucket --bucket kayan-terra-state --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2