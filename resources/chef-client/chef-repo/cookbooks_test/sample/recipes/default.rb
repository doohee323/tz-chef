bash "print ohai info" do
user 'vagrant'
group 'vagrant'
cwd '/home/vagrant'
environment "HOME" =&gt; '/home/vagrant'
code &lt; /tmp/ohai.txt
EOC
creates "/tmp/ohai.txt"
end