#!/usr/bin/env bash

su -

set -x

export PROJ_NAME=chef
export PROJ_DIR=/home/vagrant
export SRC_DIR=/vagrant/resources

echo '' >> $PROJ_DIR/.bashrc
echo 'export PATH=$PATH:.' >> $PROJ_DIR/.bashrc
echo 'export PROJ_DIR='$PROJ_DIR >> $PROJ_DIR/.bashrc
echo 'export SRC_DIR='$SRC_DIR >> $PROJ_DIR/.bashrc
source $PROJ_DIR/.bashrc

echo '' >> /etc/hosts
echo '192.168.82.170    chef.tz.com' >> /etc/hosts
echo '192.168.82.171    client.tz.com' >> /etc/hosts

#sudo sh -c "echo '' >> /etc/hosts"
#sudo sh -c "echo '192.168.82.170    chef.tz.com' >> /etc/hosts"
#sudo sh -c "echo '192.168.82.171    client.tz.com' >> /etc/hosts"

sudo apt-get update

cd $PROJ_DIR
wget https://packages.chef.io/files/stable/chef-server/12.14.0/ubuntu/16.04/chef-server-core_12.14.0-1_amd64.deb
sudo dpkg -i chef-server-core_12.14.0-1_amd64.deb
sudo chef-server-ctl reconfigure

sudo mkdir -p /vagrant/.ssh
sudo chef-server-ctl user-create admin Dewey Hong admin@gmail.com 'admin123' --filename /vagrant/.ssh/admin.pem
sudo chef-server-ctl org-create topzone 'topzone.com' --association_user admin --filename /vagrant/.ssh/topzone-validator.pem

# for client work
sudo cp /vagrant/.ssh/admin.pem /vagrant/resources/chef-client/chef-repo/.chef

# Chef Manage
sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license

# Chef Push Jobs
sudo chef-server-ctl install opscode-push-jobs-server
sudo chef-server-ctl reconfigure
sudo opscode-push-jobs-server-ctl reconfigure

# Reporting
sudo chef-server-ctl install opscode-reporting
sudo chef-server-ctl reconfigure --accept-license
sudo opscode-reporting-ctl reconfigure --accept-license

# use trusted_certs
sudo mkdir -p /home/vagrant/.chef/trusted_certs
sudo cp /var/opt/opscode/nginx/ca/chef.tz.com.crt /home/vagrant/.chef/trusted_certs
sudo mkdir -p /home/vagrant/chef-repo/.chef/trusted_certs
sudo cp /var/opt/opscode/nginx/ca/chef.tz.com.crt /home/vagrant/chef-repo/.chef/trusted_certs
sudo chown -Rf vagrant:vagrant /home/vagrant/.chef/trusted_certs
# knife ssl check

# copy trusted_certs for client.tz.com's startkit
sudo rm -Rf /vagrant/resources/chef-client/chef-repo/.chef/trusted_certs
sudo cp -Rf /home/vagrant/.chef/trusted_certs /vagrant/resources/chef-client/chef-repo/.chef

cd $PROJ_DIR
wget https://packages.chef.io/files/stable/chef/12.19.36/ubuntu/16.04/chef_12.19.36-1_amd64.deb
sudo dpkg -i chef_12.19.36-1_amd64.deb

cd /vagrant/resources/chef-client/chef-repo/.chef

# knife command works fine under .chef directory without any env. configuration. 
knife client list

exit 0
