#
# Cookbook Name:: TeamCity
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#

::Chef::Recipe.send(:include,Opscode::OpenSSL::Password)

include_recipe "runit"
include_recipe "java"
include_recipe "nginx::source"
require_recipe "database"

node.set_unless[:teamcity][:database][:password] = secure_password
node.save unless Chef::Config[:solo]

user node[:teamcity][:run_user] do
  system true
  home node[:teamcity][:home_path]
  shell "/bin/bash"
end

group node[:teamcity][:run_user] do
  members [ node[:teamcity][:run_user] ]
  append true
end

directory "/var/www/tools" do
  recursive true
  owner "www-data"
  group "www-data"
  mode 0755
end

remote_file "teamcity" do
  path "#{Chef::Config[:file_cache_path]}/teamcity.tar.gz"
  source "http://download.jetbrains.com/teamcity/TeamCity-#{node[:teamcity][:version]}.tar.gz"
  not_if { File.exists?("#{Chef::Config[:file_cache_path]}/teamcity.tar.gz")}
end
  
bash "untar-teamcity" do
  cwd Chef::Config[:file_cache_path]
  code "tar zxvf teamcity.tar.gz"
  not_if { FileTest.exists?(node[:teamcity][:install_path]) }
end
  
bash "install-teamcity" do
  code "mv #{Chef::Config[:file_cache_path]}/TeamCity #{node[:teamcity][:install_path]}"
  not_if { FileTest.exists?(node[:teamcity][:install_path]) }
  notifies :run, "bash[set teamcity owner]", :immediately
end

bash "set teamcity owner" do
  code <<-CMD
  chown -hR #{node[:teamcity][:run_user]}:#{node[:teamcity][:run_user]} #{node[:teamcity][:install_path]}
  CMD
  action :nothing
end

%w{ / /config /lib/jdbc }.each do |homedir|
  directory "#{node[:teamcity][:home_path]}#{homedir}" do
    recursive true
    owner node[:teamcity][:run_user]
    group node[:teamcity][:run_user]
    mode 0755
  end
end

directory "/var/log/teamcity" do
  owner node[:teamcity][:run_user]
  group node[:teamcity][:run_user]
  mode 0755
end

link "#{node[:teamcity][:install_path]}/logs" do
  to "/var/log/teamcity"
  owner node[:teamcity][:run_user]
  group node[:teamcity][:run_user]
end

template "#{node[:teamcity][:home_path]}/config/database.properties" do
  source "database.#{node[:teamcity][:database][:type]}.properties.dist.erb"
  owner node[:teamcity][:run_user]
  group node[:teamcity][:run_user]
  mode 0755
end
  
if node[:teamcity][:database][:type] == "mysql"
  include_recipe "mysql::server"

  mysql_connection = {
    :host => node[:teamcity][:database][:host] || node[:mysql][:bind_address],
    :username => node[:mysql][:root],
    :password => node[:mysql][:server_root_password]
  }

  mysql_database node[:teamcity][:database][:name] do
    connection mysql_connection
    action :create
  end
    
  mysql_database_user node[:teamcity][:database][:user] do
    connection mysql_connection
    password node[:teamcity][:database][:password]
    database_name node[:teamcity][:database][:name]
    host node[:teamcity][:database][:host] || node[:mysql][:bind_address]
    action [ :create, :grant]
  end
    
  mysql_connector "#{node[:teamcity][:home_path]}/lib/jdbc"
    
elsif node[:teamcity][:database][:type] == "postgresql"
  include_recipe "postgresql::server"

  connection = {
    :host => node[:teamcity][:database][:host], 
    :username => node[:postgresql][:root],
    :password => node[:postgresql][:password][:postgres]
  }

  postgresql_database node[:teamcity][:database][:name] do
    connection connection
    action :create
  end
    
  postgresql_database_user node[:teamcity][:database][:user] do
    connection connection
    privileges ['ALL']
    password node[:teamcity][:database][:password]
    database_name node[:teamcity][:database][:name]
    host node[:teamcity][:database][:host]
    action [ :create, :grant]
  end

  postgresql_connector "#{node[:teamcity][:home_path]}/lib/jdbc"

end

#scribe_log4j "#{node[:teamcity][:install_path]}/lib/" do
#  only_if { node[:teamcity][:server][:log][:scribe] }
#end

#template "#{node[:teamcity][:install_path]}/conf/teamcity-server-log4j.xml" do
#  owner node[:teamcity][:run_user]
#  group node[:teamcity][:run_user]
#  mode 0644
#  only_if { node[:teamcity][:server][:log][:scribe] }
#end

directory "#{node[:teamcity][:home_path]}/.ssh" do
  owner node[:teamcity][:run_user]
  group node[:teamcity][:run_user]
  mode 0700
end

template "/etc/nginx/sites-available/teamcity" do
  source "teamcity.erb"
end

nginx_site "teamcity"

directory node[:teamcity][:build_dir] do  
  recursive true
end

directory "#{node[:teamcity][:build_dir]}/helpers" do  
end

directory "#{node[:teamcity][:build_dir]}/libs" do  
end

cookbook_file "#{node[:teamcity][:build_dir]}/helpers/phpunit_to_junit.xsl" do
end

runit_service "teamcity" do
    run_restart false
end

#backup "teamcitydb" do
#  only_if { node[:teamcity][:server][:backup] }
#  action :dump
#end