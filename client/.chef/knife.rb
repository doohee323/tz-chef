# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "admin"
client_key               "/home/vagrant/chef-repo/.chef/admin.pem"
chef_server_url          "https://chef.tz.com/organizations/topzone"
cookbook_path            ["/home/vagrant/chef-repo/cookbooks"]
cache_path 				 "/home/vagrant/chef-repo/.chef"
ssl_verify_mode    		 :verify_none

