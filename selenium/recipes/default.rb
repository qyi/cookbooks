#
# Cookbook Name:: selenium
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "runit"
include_recipe "java"
include_recipe "nginx::source"

directory node[:selenium][:install_path]

remote_file "selenium-server-standalone" do
  path "#{node[:selenium][:install_path]}/selenium-server-standalone.jar"
  source "http://selenium.googlecode.com/files/selenium-server-standalone-#{node[:selenium][:version]}.jar"
  not_if { File.exists?("#{node[:selenium][:install_path]}/selenium-server-standalone.jar")}
end
