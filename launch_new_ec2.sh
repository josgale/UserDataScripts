#!/bin/bash

# The following script will launch a new EC2 instance and configure it with the user data from file://lamp_db_install.sh
# This will install a lamp stack, mediawiki and configure tls


aws ec2 run-instances --image-id ami-0dc2d3e4c0f9ebd18 --count 1 --region us-east-1 --instance-type t2.micro \
--key-name webServer2 --subnet-id subnet-xxxxxx --security-group-ids sg-xxxxxx \
--user-data file://lamp_db_install.sh

