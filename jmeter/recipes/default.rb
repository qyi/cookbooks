# Cookbook Name:: ant
#
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
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
include_recipe "java"

remote_file "#{Chef::Config[:file_cache_path]}/jmeter.tgz" do
  source "http://www.sai.msu.su/apache//jmeter/binaries/apache-jmeter-#{node['jmeter']['version']}.tgz"
  not_if { File.exists? "#{Chef::Config[:file_cache_path]}/jmeter.tgz" }
end

execute "extract jmeter" do
  cwd Chef::Config[:file_cache_path]
  command "tar -zxvf #{Chef::Config[:file_cache_path]}/jmeter.tgz"
  not_if { File.exists? "#{Chef::Config[:file_cache_path]}/apache-jmeter-#{node['jmeter']['version']}" }
end

execute "copy to lib" do
  cwd Chef::Config[:file_cache_path]
  command "cp -r apache-jmeter-#{node['jmeter']['version']} #{node['jmeter']['install_path']}"
  not_if { File.exists? node['jmeter']['install_path'] }
end  