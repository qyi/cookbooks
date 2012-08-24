#
# Cookbook Name:: jira
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
# Manual Steps!
#
# MySQL:
#
#   create database jiradb character set utf8;
#   grant all privileges on jiradb.* to '$jira_user'@'localhost' identified by '$jira_password';
#   flush privileges;

::Chef::Recipe.send(:include,Opscode::OpenSSL::Password)

include_recipe "runit"
include_recipe "java"
include_recipe "nginx::source"
require_recipe "database"

node.set_unless[:jira][:database][:password] = secure_password
node.save unless Chef::Config[:solo]

user node[:jira][:run_user] do
  system true
  home node[:jira][:home_path]
  shell "/bin/bash"
end

group node[:jira][:run_user] do
  members [ node[:jira][:run_user] ]
  append true
end

directory "/var/www/tools" do
  owner "www-data"
  group "www-data"
  recursive true
end

remote_file "#{Chef::Config[:file_cache_path]}/jira-#{node[:jira][:version]}.tar.gz" do
  source "http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-#{node[:jira][:version]}.tar.gz"
  not_if { File.exists?("#{Chef::Config[:file_cache_path]}/jira-#{node[:jira][:version]}.tar.gz") }
end
  
bash "untar-jira" do
  cwd Chef::Config[:file_cache_path]
  code "tar zxvf jira-#{node[:jira][:version]}.tar.gz"
  not_if { File.exists?(node[:jira][:install_path]) }
end
  
bash "install-jira" do
  code "mv #{Chef::Config[:file_cache_path]}/atlassian-jira-#{node[:jira][:version]}-standalone #{node[:jira][:install_path]}"
  not_if { File.exists?(node[:jira][:install_path]) }
  notifies :run, "bash[set jira owner]", :immediately
end

bash "set jira owner" do
  code <<-CMD
  chown -hR #{node[:jira][:run_user]}:#{node[:jira][:run_user]} #{node[:jira][:install_path]}
  CMD
  action :nothing
end

cookbook_file "#{node[:jira][:install_path]}/bin/startup.sh" do  
  source "startup.sh"
  owner node[:jira][:run_user]
  group node[:jira][:run_user]
  mode 0755
end

%w{ / /repositories }.each do |homedir|
  directory "#{node[:jira][:home_path]}#{homedir}" do
    recursive true
    owner node[:jira][:run_user]
    group node[:jira][:run_user]
   mode 0755
  end
end

template "#{node[:jira][:home_path]}/dbconfig.xml" do
  source "#{node[:jira][:database][:type]}.dbconfig.xml.erb"    
  owner node[:jira][:run_user]
  group node[:jira][:run_user]
  mode 0755
end 

if node[:jira][:database][:type] == "mysql"
  include_recipe "mysql"

  mysql_connection = {
    :host => node[:jira][:database][:host] || node[:mysql][:bind_address], 
    :username => node[:mysql][:root], 
    :password => node[:mysql][:server_root_password]
  }
  
  mysql_database node[:jira][:database][:name] do
    connection mysql_connection
    action :create
  end
    
  mysql_database_user node[:jira][:database][:user] do
    connection mysql_connection
    password node[:jira][:database][:password]
    database_name node[:jira][:database][:name]
    host node[:jira][:database][:host] || node[:mysql][:bind_address]
    action [ :create, :grant]
  end

  #add owner adn group params
  mysql_connector "#{node[:jira][:install_path]}/lib"

elsif node[:jira][:database][:type] == "postgresql"
  include_recipe "postgresql::server"

  connection = {
    :host => node[:jira][:database][:host], 
    :username => node[:postgresql][:root],
    :password => node[:postgresql][:password][:postgres]
  }

  postgresql_database node[:jira][:database][:name] do
    connection connection
    action :create
  end
    
  postgresql_database_user node[:jira][:database][:user] do
    connection connection
    privileges ['ALL']
    password node[:jira][:database][:password]
    database_name node[:jira][:database][:name]
    host node[:jira][:database][:host]
    action [ :create, :grant]
  end

  postgresql_connector "#{node[:jira][:install_path]}/lib"

end

template "/etc/nginx/sites-available/jira" do
  source "jira.erb"
end

directory "#{node[:jira][:home_path]}/.ssh" do
  owner node[:jira][:run_user]
  group node[:jira][:run_user]
  mode 0700
end

nginx_site "jira"

runit_service "jira" do
    run_restart false
end