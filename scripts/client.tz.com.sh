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
wget https://packages.chef.io/files/stable/chef/12.19.36/ubuntu/16.04/chef_12.19.36-1_amd64.deb
sudo dpkg -i chef_12.19.36-1_amd64.deb

# get chef-base 
# https://github.com/cookbooks
rm -Rf /home/vagrant/chef-repo/*
rm -Rf /home/vagrant/chef-repo/.git
rm -Rf /home/vagrant/chef-repo/.chef
rm -Rf /home/vagrant/chef-repo/.chef-repo.txt
rm -Rf /home/vagrant/chef-repo/.gitignore

cd /home/vagrant
git clone https://github.com/chef/chef-repo.git
sudo chef generate repo chef-repo
cd /home/vagrant/chef-repo
git config --global user.name "Dewey Hong"
git config --global user.email "doohee323@gmail.com"
echo ".chef" >> /home/vagrant/chef-repo/.gitignore
git add .
git commit -m 'init'

# copy .chef
cp -Rf /vagrant/resources/chef-client/chef-repo/.chef /home/vagrant/chef-repo/.chef
sudo chown -Rf vagrant:vagrant /home/vagrant/chef-repo

# for run as root account
sudo rm -Rf /root/.chef
sudo ln -s /home/vagrant/chef-repo/.chef /root/.chef
sudo mkdir /etc/chef
sudo ln -s /home/vagrant/chef-repo/.chef/client.rb /etc/chef/client.rb

knife ssl check

exit 0;

cd /home/vagrant/chef-repo/.chef
# 1. create a client
export EDITOR=vi
knife client create client.tz.com -a -f /home/vagrant/chef-repo/.chef/client.tz.com.pem
#knife client delete exampleorg2 -y
knife client list

# 2. create a node
sudo chef-client -c /home/vagrant/chef-repo/.chef/client.rb -N client.tz.com

# 3. create a test cookbook

# 3.1 using public cookbook
knife cookbook site search java
knife cookbook site show java
knife cookbook site show java 1.8.0
knife cookbook site download java 1.8.0
knife cookbook site install java 1.8.0
# change default version
sed -i "s/ '6'/ '8'/g" /home/vagrant/chef-repo/cookbooks/java/attributes/default.rb

# 3.2 using custom cookbook (cookbooks_test)
# knife cookbook create sample -o /home/vagrant/chef-repo/cookbooks_test
cp -Rf /vagrant/resources/chef-client/chef-repo/cookbooks_test /home/vagrant/chef-repo/cookbooks_test

# 4. upload the test cookbook
knife cookbook upload -a -o /home/vagrant/chef-repo/cookbooks_test
knife cookbook upload -a -o /home/vagrant/chef-repo/cookbooks

# 5. add a recipe to the node(client.tz.com)
#knife cookbook delete java

knife node run_list add client.tz.com 'recipe[sample]'
knife node run_list add client.tz.com 'recipe[ohai]'
knife node run_list add client.tz.com 'recipe[java]'
#knife node run_list remove client.tz.com 'recipe[java]'
#knife node edit node01

sudo chef-client

# verify result
java -version
head /tmp/herp.conf

exit 0
