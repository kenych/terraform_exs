#!/usr/bin/env bash

yum install perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https -y
mkdir /CloudWatch
cd /CloudWatch
curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
unzip CloudWatchMonitoringScripts-1.2.1.zip
rm -rf CloudWatchMonitoringScripts-1.2.1.zip
cd aws-scripts-mon
./mon-put-instance-data.pl --mem-util --verify --verbose > CloudWatchtest.log
(crontab -l 2>/dev/null; echo "${CRON} /CloudWatch/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/ --disk-space-util --disk-space-used --disk-space-avail") | crontab -
