template "/tmp/herp.conf" do
  source "herp.conf.erb"
  variables :username => "myapp", 
  	:password => "SUPERSECRET"
  mode "0644"
end

  
