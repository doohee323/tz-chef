vip_ip_addresses = []
dev_db_hash = data_bag_item("test", "dev").to_hash
vip_data = dev_db_hash["test"]["dev"]

template "/tmp/herp.conf" do
  source "herp.conf.erb"
  variables :username => "myapp", :password => vip_data["bind_ip"]
  mode "0644"
end

  
