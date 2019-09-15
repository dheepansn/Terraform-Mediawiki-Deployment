#!/bin/bash

sudo yum clean all
sudo yum repolist
# sudo yum update -y
sudo yum -y install ansible

sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
