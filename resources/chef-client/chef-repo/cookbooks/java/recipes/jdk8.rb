#
# Cookbook Name:: java
# Recipe:: jdk8
#
# Install JDK8 in Ubuntu and run the update-alternatives.
#
# variables
jdk8_url = "http://mirror2.prod.yvr1.xdn.com/java"
jdk8_file = "jdk-8u60-linux-x64.tgz"
jdk8_version = "jdk1.8.0_60"
java_folder = "/usr/java"

# create the directory for the JDK8 to be copied to.
directory '/usr/java' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

# update the Ubuntu alternatives with default Java location
# with the highest priority.
# If we are upgrading the current JDK installation, we just need to update
# the symlink, /usr/java/default, folder to the upgraded version's folder
=begin
%w{java javac javadoc javah javap javaws javafxpackager javapackager jmap jstack jstat jstatd jcmd jconsole jcontrol jdb jdeps jinfo jps jar jarsigner jhat jrunscript jsadebugd jexec jjs}.each do |altjava|
  execute "#{altjava}" do
    command <<-EOF
        update-alternatives --install "/usr/bin/#{altjava}" "#{altjava}" "/usr/java/default/bin/#{altjava}" 99
        EOF
    action :nothing
  end
end
=end

execute "install-alt-java" do
    command <<-EOF
        update-alternatives --install "/usr/bin/java" "java" "/usr/java/default/bin/java" 99
        update-alternatives --install "/usr/bin/javac" "javac" "/usr/java/default/bin/javac" 99
        update-alternatives --install "/usr/bin/javadoc" "javadoc" "/usr/java/default/bin/javadoc" 99
        update-alternatives --install "/usr/bin/javah" "javah" "/usr/java/default/bin/javah" 99
        update-alternatives --install "/usr/bin/javap" "javap" "/usr/java/default/bin/javap" 99
        update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/java/default/bin/javaws" 99
        update-alternatives --install "/usr/bin/javafxpackager" "javafxpackager" "/usr/java/default/bin/javafxpackager" 99
        update-alternatives --install "/usr/bin/javapackager" "javapackager" "/usr/java/default/bin/javapackager" 99
        update-alternatives --install "/usr/bin/jmap" "jmap" "/usr/java/default/bin/jmap" 99
        update-alternatives --install "/usr/bin/jstack" "jstack" "/usr/java/default/bin/jstack" 99
        update-alternatives --install "/usr/bin/jstat" "jstat" "/usr/java/default/bin/jstat" 99
        update-alternatives --install "/usr/bin/jstatd" "jstatd" "/usr/java/default/bin/jstatd" 99
        update-alternatives --install "/usr/bin/jcmd" "jcmd" "/usr/java/default/bin/jcmd" 99
        update-alternatives --install "/usr/bin/jconsole" "jconsole" "/usr/java/default/bin/jconsole" 99
        update-alternatives --install "/usr/bin/jcontrol" "jcontrol" "/usr/java/default/bin/jcontrol" 99
        update-alternatives --install "/usr/bin/jdb" "jdb" "/usr/java/default/bin/jdb" 99
        update-alternatives --install "/usr/bin/jdeps" "jdeps" "/usr/java/default/bin/jdeps" 99
        update-alternatives --install "/usr/bin/jinfo" "jinfo" "/usr/java/default/bin/jinfo" 99
        update-alternatives --install "/usr/bin/jps" "jps" "/usr/java/default/bin/jps" 99
        update-alternatives --install "/usr/bin/jar" "jar" "/usr/java/default/bin/jar" 99
        update-alternatives --install "/usr/bin/jarsigner" "jarsigner" "/usr/java/default/bin/jarsigner" 99
        update-alternatives --install "/usr/bin/jhat" "jhat" "/usr/java/default/bin/jhat" 99
        update-alternatives --install "/usr/bin/jrunscript" "jrunscript" "/usr/java/default/bin/jrunscript" 99
        update-alternatives --install "/usr/bin/jsadebugd" "jsadebugd" "/usr/java/default/bin/jsadebugd" 99
        update-alternatives --install "/usr/bin/jexec" "jexec" "/usr/java/default/lib/jexec" 99
        update-alternatives --install "/usr/bin/jjs" "jjs" "/usr/java/default/bin/jjs" 99
        EOF
    action :nothing
end

=begin
# download the JDK8 tgz file, and place it under /usr/java
remote_file '/usr/java/jdk-8u60-linux-x64.tgz' do
    source 'http://mirror2.prod.yvr1.xdn.com/java/jdk-8u60-linux-x64.tgz'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    notifies :run, 'execute[jdk8prep]', :immediately
    notifies :run, 'execute[install-alt-java]', :immediately
    not_if { ::File.exists?('/usr/java/default/bin/java') }
end
=end

# download the JDK8 file from mirror2 and decompress
# and change the ownership to root:root
# and create a symlink folder, default, to the installed JDK folder (i.e. jdk1.8.0_60)
# and then delete the tgz file.
apt_package 'wget' do
  action :upgrade
end

execute 'jdk8prep' do
    cwd "#{java_folder}"
    command <<-EOF
        cd #{java_folder} && wget #{jdk8_url}/#{jdk8_file}
        tar zxvf #{jdk8_file}
        chown -R root:root #{java_folder}/#{jdk8_version}
        ln -s #{jdk8_version} default
        rm -f /usr/java/#{jdk8_file}
        EOF
    action :run
    notifies :run, 'execute[install-alt-java]', :immediately
    not_if { ::File.exists?('/usr/java/default/bin/java') }
end

# reset to the default Java executables if it is not.
%w{java javac javadoc javah javap javaws javafxpackager javapackager jmap jstack jstat jstatd jcmd jconsole jcontrol jdb jdeps jinfo jps jar jarsigner jhat jrunscript jsadebugd jexec jjs}.each do |autojava|
  execute "#{autojava}" do
    command "update-alternatives --auto \"#{autojava}\""
    action :run
    not_if "ls -l /etc/alternatives/#{autojava} | grep default"
  end
end

=begin
execute 'alt-auto-java' do
    command <<-EOF
        update-alternatives --auto "java"
        update-alternatives --auto "javac"
        update-alternatives --auto "javadoc"
        update-alternatives --auto "javah"
        update-alternatives --auto "javap"
        update-alternatives --auto "javaws"
        update-alternatives --auto "javafxpackager"
        update-alternatives --auto "javapackager"
        update-alternatives --auto "jmap"
        update-alternatives --auto "jstack"
        update-alternatives --auto "jstat"
        update-alternatives --auto "jstatd"
        update-alternatives --auto "jcmd"
        update-alternatives --auto "jconsole"
        update-alternatives --auto "jcontrol"
        update-alternatives --auto "jdb"
        update-alternatives --auto "jdeps"
        update-alternatives --auto "jinfo"
        update-alternatives --auto "jps"
        update-alternatives --auto "jar"
        update-alternatives --auto "jarsigner"
        update-alternatives --auto "jhat"
        update-alternatives --auto "jrunscript"
        update-alternatives --auto "jsadebugd"
        update-alternatives --auto "jexec"
        update-alternatives --auto "jjs"
        EOF
    action :run
    not_if 'ls -l /etc/alternatives/jjs | grep default'
end
=end
