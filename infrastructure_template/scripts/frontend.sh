#!/bin/bash
sudo yum update -y
sudo yum install -y git 

#Public ip back-end portal
sudo sh -c "echo BACKEND=${backend} >> /etc/environment"

#Clone salt repo
sudo git clone -b development https://github.com/dvlopez9811/aik-infrastructure /srv/aik-infrastructure

#Install Salstack
sudo yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm
sudo yum clean expire-cache;sudo yum -y install salt-minion; chkconfig salt-minion off

#Put custom minion config in place (for enabling masterless mode)
sudo cp -r /srv/aik-infrastructure/configuration_management/minion.d /etc/salt/

echo -e 'grains:\n roles:\n  - frontend' | sudo tee /etc/salt/minion.d/grains.conf

## Trigger a full Salt run
sudo salt-call state.apply
