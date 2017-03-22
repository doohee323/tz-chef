# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "client.tz.com"
client_key               "#{current_dir}/client.tz.com.pem"
chef_server_url          "https://chef.tz.com/organizations/topzone"
cookbook_path            ["#{current_dir}/../cookbooks"]
