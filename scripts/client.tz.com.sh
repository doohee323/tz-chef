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

sudo apt-get update

# make ssh key
ssh-keygen -t dsa -P '' -f $PROJ_DIR/.ssh/id_dsa
cat $PROJ_DIR/.ssh/id_dsa.pub >> $PROJ_DIR/.ssh/authorized_keys
echo '' >> /etc/ssh/ssh_config
echo '    ForwardX11 no' >> /etc/ssh/ssh_config
echo '    StrictHostKeyChecking no' >> /etc/ssh/ssh_config
sudo chown -Rf vagrant:vagrant $PROJ_DIR/.ssh
sudo chmod -Rf 600 $PROJ_DIR/.ssh/*

#sudo mkdir -p /etc/chef
#sudo cp /vagrant/.ssh/validation.pem /etc/chef/validation.pem
#sudo chown -Rf vagrant:vagrant /etc/chef/validation.pem
#sudo chmod 600 /etc/chef/validation.pem
#sudo cp /vagrant/.ssh/client.pem /etc/chef/client.tz.com.pem
#sudo chown -Rf vagrant:vagrant /etc/chef/client.tz.com.pem
#sudo chmod 600 /etc/chef/client.tz.com.pem

cd $PROJ_DIR
wget https://packages.chef.io/files/current/chef/12.19.37/ubuntu/16.04/chef_12.19.37-1_amd64.deb
sudo dpkg -i chef_12.19.37-1_amd64.deb

sudo rm -Rf /home/vagrant/chef-repo
sudo cp -Rf /vagrant/resources/chef-client/chef-repo /home/vagrant
sudo chown -Rf vagrant:vagrant /home/vagrant/chef-repo

cd /home/vagrant/chef-repo/.chef

# create client
export EDITOR=vi
knife client create client.tz.com -a -f /home/vagrant/chef-repo/.chef/client.tz.com.pem
knife client list

# create node
sudo chef-client -c /home/vagrant/chef-repo/.chef/client.rb -N client.tz.com

exit 0
