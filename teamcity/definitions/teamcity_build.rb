#
# Cookbook Name:: nginx
# Definition:: nginx_site
# Author:: AJ Christensen <aj@junglist.gen.nz>
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

define :teamcity_build, :builds => ["build.xml"] do
  
  directory "#{node[:teamcity][:build_dir]}/#{params[:name]}" do
    owner "root"
    group "root"
    mode 0755
    recursive true
    not_if {File.exists?("#{node[:teamcity][:build_dir]}/#{params[:name]}")}
  end  
  
  %w{ config }.each do |dir|
      directory "#{node[:teamcity][:build_dir]}/#{params[:name]}/#{dir}" do
        owner "root"
        group "root"
        mode 0755
        not_if {File.exists?("#{node[:teamcity][:build_dir]}/#{params[:name]}/#{dir}")}
      end
  end
  
  params[:variables] = Hash.new unless params[:variables]
  params[:variables][:build] = "#{node[:teamcity][:build_dir]}/#{params[:name]}"
  
  if params[:builds].class == Array
    params[:builds].each do |build|
      template "#{node[:teamcity][:build_dir]}/#{params[:name]}/config/#{build}" do
        source params[:development_build]
        cookbook params[:cookbook] ? params[:cookbook] : "teamcity"
        variables(params[:variables])
      end  
    end
  end

  if params[:builds].class == Hash
    params[:builds].each do |build, source|      
      template "#{node[:teamcity][:build_dir]}/#{params[:name]}/config/#{build}" do
        source source
        cookbook params[:cookbook] ? params[:cookbook] : "teamcity"
        variables(params[:variables])
      end  
    end
  end
end
