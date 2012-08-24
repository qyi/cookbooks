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

::Chef::Recipe.send(:include,Opscode::OpenSSL::Password)

include_recipe "java"
include_recipe "php"
include_recipe "python"
include_recipe "rvm"
include_recipe "sudo"

package "unzip"

directory node['teamcity']['agent']['dir'] do
  recursive true
end

user node['teamcity']['agent']['user'] do
  system true
  home node['teamcity']['agent']['dir']
  shell "/bin/bash"
end

group node['teamcity']['agent']['user'] do
  members [ node['teamcity']['agent']['user'] ]
  append true
end

sudo node['teamcity']['agent']['user'] do
  user node['teamcity']['agent']['user']
  runas "ALL"
  commands ["ALL"]
  host "ALL"
  nopasswd true
end

execute "ssh-keygen -t rsa -f #{node['teamcity']['agent']['dir']}/.ssh/deploy -q -P ''" do
  not_if { File.exists? "#{node['teamcity']['agent']['dir']}/.ssh/deploy" }
end

ruby_block "add auth key" do
  block do
    pub = `cat #{node['teamcity']['agent']['dir']}/.ssh/deploy.pub`
    deploy = data_bag_item("users", "deploy")
    unless deploy["ssh_keys"]
      deploy["ssh_keys"] = Array.new
    end
    unless deploy["ssh_keys"].index(pub)
      deploy["ssh_keys"] << pub
      deploy.save
    end
  end
  action :create
end

if Chef::Config['solo']
  # create if server in run list, add self
  # servers = [node]
  servers = []
else
  servers = search(:node, 'recipes:teamcity\:\:server')
end

servers.each do |server|

  name = server.name.downcase

  remote_file "#{Chef::Config[:file_cache_path]}/#{name}buildAgent.zip" do
    source "http://#{server['teamcity']['virtual_host_name']}/update/buildAgent.zip"
    not_if { File.exists?("#{Chef::Config[:file_cache_path]}/#{name}buildAgent.zip") }
  end

  execute "unzip #{Chef::Config[:file_cache_path]}/#{name}buildAgent.zip -d #{node['teamcity']['agent']['dir']}/#{name}" do
    not_if { File.exists?("#{node['teamcity']['agent']['dir']}/#{name}") }
  end

  execute "set permissions" do
    command "chown -hR #{node['teamcity']['agent']['user']}:#{node['teamcity']['agent']['group']} #{node['teamcity']['agent']['dir']}/#{name}"
  end

  template "#{node['teamcity']['agent']['dir']}/#{name}/conf/buildAgent.properties" do
    owner node['teamcity']['agent']['user']
    group node['teamcity']['agent']['group']
    variables( :server => server['teamcity']['virtual_host_name']) 
  end

  template "/etc/init.d/teamcity-#{name}-agent" do
    source "teamcity-agent.erb"
    variables( :name => "teamcity-#{name}-agent", :path => "#{node['teamcity']['agent']['dir']}/#{name}")
    mode 0755
  end

  execute "chmod +x bin/agent.sh" do
    cwd "#{node['teamcity']['agent']['dir']}/#{name}"
  end

  service "teamcity-#{name}-agent" do
    action [ :enable, :start ]
  end

  execute "update-rc.d" do
    command "update-rc.d teamcity-#{name}-agent defaults"
  end

end