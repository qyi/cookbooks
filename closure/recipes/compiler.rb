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

directory node['closure']['compiler']['dir'] do
  recursive true
end

remote_file "#{Chef::Config[:file_cache_path]}/compiler-latest.zip" do
  source "http://closure-compiler.googlecode.com/files/compiler-latest.zip"
  not_if { File.exists? "#{Chef::Config[:file_cache_path]}/compiler-latest.zip" }
end

execute "install closure compiler" do
  cwd node['closure']['compiler']['dir']
  command <<-CMD
    unzip #{Chef::Config[:file_cache_path]}/compiler-latest.zip
    chmod -R 644 node['closure']['compiler']['dir']
  CMD
  not_if { File.exists? "#{node['closure']['compiler']['dir']}/compiler.jar" }
end