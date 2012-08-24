#
# Cookbook Name:: boost
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
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

include_recipe "build-essential"
include_recipe "python"

%w{ libbz2-dev subversion }.each do |pkg|
  package pkg
end

subversion "boost" do
  repository "http://svn.boost.org/svn/boost/tags/release/Boost_#{node[:boost][:version].gsub!(".","_")}/"
  destination "/tmp/boost"  
  action :sync
  not_if { File.exists? "/usr/include/boost" }
end

bash "install-boost" do
  cwd "/tmp/boost"
  code <<-EOH
  ./bootstrap.sh --prefix=/usr
  ./bjam 
  ./bjam install
  EOH
  action :run
  not_if { File.exists? "/usr/include/boost" }
end

