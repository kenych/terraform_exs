#!/usr/bin/env bash

aws s3api create-bucket --bucket kayan-terra-state --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2