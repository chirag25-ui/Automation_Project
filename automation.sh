#!/bin/bash

##Initialize variables
#update the variable with the s3 bucket name in aws
s3_bucket="upgrad-chirag"
#provide the prefix that needs to be used to archive file on s3 bucket
fileprefix="webserver"

# Download package information from all configured sources
apt update -y

# Check if apache http server is installed. Install if not installed already
installstat=$(dpkg --get-selections | grep apache2)

if [[ $installstat == *"apache2"* ]]; then
    echo "Apache process is installed..."
else
    echo "Apache process is not installed. Hence installing the service..."
    apt install apache2 -y
fi

# Check if apache http server is running. Start server if not running already
servstat=$(systemctl status apache2)

if [[ $servstat == *"active (running)"* ]]; then
    echo "Apache process is running..."
else
    echo "Apache process is not running. Hence starting the service..."
    systemctl start apache2
fi

# Check if apache http server is enabled. Start server if not enabled already
enablestat=$(systemctl --all list-unit-files --type=service | grep -i "apache2")

if [[ $enablestat == *"enabled"* ]]; then
    echo "Apache process is enabled..."
else
    echo "Apache process is not enabled. Hence enabling the service..."
    systemctl enable apache2
fi

# Check if aws cli is installed. Install if not installed already
awscliinstallstat=$(dpkg --get-selections | grep -i "awscli")
if [[ $awscliinstallstat == *"awscli"* ]]; then
    echo "AWS cli is installed..."
else
    echo "AWS cli is not installed. Hence installing the service..."
    apt install awscli -y
fi


#check if s3 bucket indicated exists. If not exit indicating error
s3bucketstat=$(aws s3 ls | grep -i "$s3bucket")
if [[ $s3bucketstat == *"$s3bucket"*  ]]; then
    echo "AWS cli is configured and can access s3 bucket..."
else
    echo "AWS cli is not configured or s3 bucket name is incorrect. Log Archival will not proceed further..."
    exit 1
fi
