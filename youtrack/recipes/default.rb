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

include_recipe "runit"
include_recipe "java"
include_recipe "nginx::source"

directory node['youtrack']['install_path'] do
  recursive true
  owner "www-data"
  group "www-data"
  mode 0755
end

remote_file "download youtrack" do
  path "#{node['youtrack']['install_path']}/youtrack.jar"
  source "http://download.jetbrains.com/charisma/youtrack-#{node['youtrack']['version']}.jar"
  not_if { File.exists? "#{node['youtrack']['install_path']}/youtrack.jar" }
end

runit_service "youtrack" do
    run_restart false
end

template "/etc/nginx/sites-available/youtrack" do
  source "youtrack.erb"
end

nginx_site "youtrack"

