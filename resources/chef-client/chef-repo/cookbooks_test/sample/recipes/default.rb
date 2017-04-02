dev_db_hash = data_bag_item("test", "dev").to_hash

Chef::Log.warn "=====================test: #{dev_db_hash["test"]} ================="
Chef::Log.warn "=====================test/dev: #{dev_db_hash["test"]["dev"]} ================="
dev1 = dev_db_hash["test"]["dev"]
Chef::Log.warn "=====================dev1: #{dev1} ================="
Chef::Log.warn "=====================dev1: #{dev1["bind_ip"]} ================="

dev = data_bag('test')
Chef::Log.warn "=====================dev: #{dev} ================="

dev2 = data_bag_item('test', 'dev')
Chef::Log.warn "=====================dev2: #{dev2} ================="
Chef::Log.warn "=====================ids: #{dev2["id"]} ================="

template "/tmp/herp.conf" do
	source "herp.conf.erb"
	variables :username => "myapp", :password => dev1["bind_ip"]
	mode "0644"
end

case node.chef_environment
when "_default"
	Chef::Log.warn "=====================_default!!! ================="
when "prod"
	Chef::Log.warn "=====================prod: #{node['java']['version']} ================="
when "development"
	Chef::Log.warn "=====================development: #{node['java']['version']} ================="
end
  