#
# Cookbook Name:: cloud9
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "libv8"
include_recipe "git"
include_recipe "build-essential"
include_recipe "npm"
include_recipe "libssl"
include_recipe "libxml"
include_recipe "acl"

npm_package "sm"

user node['cloud9']['user'] do
  system true
  shell "/bin/bash"
end

git "clone cloud9" do
  destination node['cloud9']['install']
  repository "https://github.com/ajaxorg/cloud9.git"
  reference node['cloud9']['revision']
  action :sync
end

execute "install cloud9" do
  cwd node['cloud9']['install']
  command "sudo sm install"
end